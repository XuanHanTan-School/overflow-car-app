import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time_trial_api/src/time_trial.dart';
import 'package:uuid/uuid.dart';

class TimeTrialManager {
  static final _timeTrialController = BehaviorSubject<TimeTrial>();
  static StreamSubscription<DatabaseEvent>? _timeTrialStreamSubscription;
  static final _timeTrialDeleteController = BehaviorSubject<String>();
  static StreamSubscription<DatabaseEvent>? _timeTrialDeleteStreamSubscription;

  static DatabaseReference get _dbRef =>
      FirebaseDatabase.instance.ref("trials");

  static Future<void> startTimeTrialListeners() async {
    _timeTrialStreamSubscription =
        StreamGroup.merge([_dbRef.onChildAdded, _dbRef.onChildChanged])
            .listen((event) {
      final timeTrial = TimeTrial.fromMap(
          event.snapshot.key!, Map.from(event.snapshot.value as Map));
      _timeTrialController.add(timeTrial);
    });

    _timeTrialDeleteStreamSubscription = _dbRef.onChildRemoved.listen((event) {
      _timeTrialDeleteController.add(event.snapshot.key!);
    });
  }

  static Stream<TimeTrial> getTimeTrialUpdates() => _timeTrialController.stream;

  static Stream<String> getTimeTrialDeletes() =>
      _timeTrialDeleteController.stream;

  static Future<List<LeaderboardTimeTrial>> getLeaderboardTimeTrials(
      String userTrialId) async {
    final trialsSnapshot = await _dbRef.orderByChild("duration").get();
    final List<LeaderboardTimeTrial> trials = [];
    final trialSnapshotList = trialsSnapshot.children.toList();
    var position = 0;
    int? prevDuration;
    for (final eachTrialData in trialSnapshotList) {
      final trial = LeaderboardTimeTrial.fromMap(
        eachTrialData.key!,
        Map.from(eachTrialData.value as Map),
        position: position,
      );
      if (trial.duration == null) continue;

      final currentDuration = trial.duration!.inMilliseconds;
      if (prevDuration != null && prevDuration != currentDuration) {
        position++;
      }
      prevDuration = currentDuration;
      trial.position = position;
      trials.add(trial);
    }

    final userTrialIndex =
        trials.indexWhere((eachTrial) => eachTrial.id == userTrialId);
    if (userTrialIndex <= 2) {
      // Return top 10
      return trials.sublist(0, min(10, trials.length));
    }

    // Return top 3 + upper 3 + lower 3
    final leaderboard = trials.sublist(0, min(3, trials.length)) +
        trials.sublist(max(0, userTrialIndex - 3), min(userTrialIndex + 4, trials.length));
    final Set<String> uniqueIds = {};
    leaderboard.retainWhere((eachTrial) => uniqueIds.add(eachTrial.id));
    return leaderboard;
  }

  static Future<void> addTimeTrial({required String carName}) async {
    final trial = TimeTrial(id: Uuid().v4(), carName: carName);
    await _dbRef.child(trial.id).set(trial.toMap());
  }

  static Future<void> dispose() async {
    await _timeTrialStreamSubscription?.cancel();
    await _timeTrialDeleteStreamSubscription?.cancel();
  }
}

class LeaderboardTimeTrial extends TimeTrial {
  int position;

  LeaderboardTimeTrial({
    required super.id,
    required super.userName,
    required super.startTime,
    required super.endTime,
    required super.carName,
    required this.position,
    required super.duration,
  });

  factory LeaderboardTimeTrial.fromMap(
    String id,
    Map<String, dynamic> map, {
    required int position,
  }) {
    return LeaderboardTimeTrial(
      id: id,
      userName: map["userName"],
      startTime: TimeTrial.convertToDateTime(map["startTime"]),
      endTime: TimeTrial.convertToDateTime(map["endTime"]),
      carName: map["carName"],
      position: position,
      duration: TimeTrial.convertToDuration(map["duration"]),
    );
  }
}
