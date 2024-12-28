import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time_trial_api/time_trial_api.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class TimeTrialBloc extends Bloc<TimeTrialEvent, TimeTrialState> {
  BehaviorSubject<TimeTrial?>? _currentTimeTrialStreamController;
  StreamSubscription<TimeTrial>? _timeTrialUpdatesStreamSubscription;
  StreamSubscription<String>? _timeTrialDeletesStreamSubscription;

  final List<TimeTrial> _allTimeTrials = [];

  TimeTrialBloc() : super(TimeTrialState()) {
    on<TimeTrialAppInitialize>(onAppInitialize);
    on<SetCar>(onSetCar);
    on<AddTimeTrial>(onAddTimeTrial);
    on<UpdateCurrentTrial>(onUpdateCurrentTrial);
    on<ListenToLeaderboard>(onListenToLeaderboard);
    on<RefreshLeaderboard>(onRefreshLeaderboard);
    on<ResetTimeTrialBloc>(onResetTimeTrialBloc);
  }

  Future<void> onAppInitialize(
      TimeTrialAppInitialize event, Emitter emit) async {
    await TimeTrialManager.startTimeTrialListeners();
  }

  Future<void> setupTimeTrialStreamController() async {
    await _timeTrialUpdatesStreamSubscription?.cancel();
    await _timeTrialDeletesStreamSubscription?.cancel();
    await _currentTimeTrialStreamController?.close();
    _currentTimeTrialStreamController = BehaviorSubject();

    _timeTrialUpdatesStreamSubscription =
        TimeTrialManager.getTimeTrialUpdates().listen((trial) {
      if (trial.carName != state.carName) return;

      _currentTimeTrialStreamController?.add(trial);
    });

    _timeTrialDeletesStreamSubscription =
        TimeTrialManager.getTimeTrialDeletes().listen((trialId) async {
      if (trialId != (_currentTimeTrialStreamController?.value)?.id) {
        return;
      }

      _currentTimeTrialStreamController?.add(null);
    });
  }

  Future<void> onSetCar(SetCar event, Emitter emit) async {
    emit(state.copyWithCarName(carName: event.carName));

    await setupTimeTrialStreamController();
    await for (final currentTrial
        in _currentTimeTrialStreamController!.stream) {
      emit(state.copyWithCurrentTrial(currentTrial: currentTrial));
    }
  }

  Future<void> onAddTimeTrial(AddTimeTrial event, Emitter emit) async {
    await TimeTrialManager.addTimeTrial(carName: event.carName);
  }

  Future<void> onUpdateCurrentTrial(
      UpdateCurrentTrial event, Emitter emit) async {
    assert(state.currentTrial != null);

    final currentTrial = state.currentTrial!;
    Duration? duration;
    if (event.endTime != null) {
      assert(currentTrial.startTime != null);
      duration = event.endTime!.difference(currentTrial.startTime!);
    }

    await currentTrial.update(
      userName: event.userName,
      startTime: event.startTime,
      endTime: event.endTime,
      duration: duration,
    );
  }

  Future<void> onListenToLeaderboard(
      ListenToLeaderboard event, Emitter emit) async {
    await _timeTrialUpdatesStreamSubscription?.cancel();
    await _timeTrialDeletesStreamSubscription?.cancel();

    _timeTrialUpdatesStreamSubscription =
        TimeTrialManager.getTimeTrialUpdates().listen((trial) {
      _allTimeTrials.removeWhere((eachTrial) => eachTrial.id == trial.id);
      _allTimeTrials.add(trial);

      final leaderboard =
          TimeTrialManager.convertAllTimeTrialsToLeaderboard(_allTimeTrials);
      emit(state.copyWith(leaderboard: leaderboard));
    });

    _timeTrialDeletesStreamSubscription =
        TimeTrialManager.getTimeTrialDeletes().listen((trialId) async {
      _allTimeTrials.removeWhere((eachTrial) => eachTrial.id == trialId);
      final leaderboard =
          TimeTrialManager.convertAllTimeTrialsToLeaderboard(_allTimeTrials);
      emit(state.copyWith(leaderboard: leaderboard));
    });
  }

  Future<void> onRefreshLeaderboard(
      RefreshLeaderboard event, Emitter emit) async {
    final leaderboard =
        await TimeTrialManager.getLeaderboardTimeTrials(event.userTrialId);
    emit(state.copyWith(leaderboard: leaderboard));
  }

  Future<void> onResetTimeTrialBloc(
      ResetTimeTrialBloc event, Emitter emit) async {
    await _timeTrialUpdatesStreamSubscription?.cancel();
    await _timeTrialDeletesStreamSubscription?.cancel();
    await _currentTimeTrialStreamController?.close();

    _timeTrialUpdatesStreamSubscription = null;
    _timeTrialDeletesStreamSubscription = null;
    _currentTimeTrialStreamController = null;

    emit(TimeTrialState());
  }
}
