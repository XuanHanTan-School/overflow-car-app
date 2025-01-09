import 'package:firebase_database/firebase_database.dart';

class TimeTrial {
  final String id;
  final String? userName;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;
  final Duration? addedTime;
  final String carName;

  DatabaseReference get _dbRef =>
      FirebaseDatabase.instance.ref("trials").child(id);

  const TimeTrial({
    required this.id,
    this.userName,
    this.startTime,
    this.endTime,
    this.duration,
    this.addedTime,
    required this.carName,
  });

  static DateTime? convertToDateTime(int? millisecondsSinceEpoch) {
    if (millisecondsSinceEpoch == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  static Duration? convertToDuration(int? milliseconds) {
    if (milliseconds == null) return null;

    return Duration(milliseconds: milliseconds);
  }

  factory TimeTrial.fromMap(String id, Map<String, dynamic> map) {
    return TimeTrial(
      id: id,
      userName: map["userName"],
      startTime: convertToDateTime(map["startTime"]),
      endTime: convertToDateTime(map["endTime"]),
      duration: convertToDuration(map["duration"]),
      addedTime: convertToDuration(map["addedTime"]),
      carName: map["carName"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userName": userName,
      "startTime": startTime?.millisecondsSinceEpoch,
      "endTime": endTime?.millisecondsSinceEpoch,
      "duration": duration?.inMilliseconds,
      "addedTime": addedTime?.inMilliseconds,
      "carName": carName,
    };
  }

  Future<void> reset() async {
    final newTrial = TimeTrial(id: id, carName: carName, userName: userName);
    await _dbRef.set(newTrial.toMap());
  }

  Future<void> update(
      {String? userName,
      DateTime? startTime,
      DateTime? endTime,
      Duration? addedTime,
      Duration? duration}) async {
    final newTrial = copyWith(
      userName: userName,
      startTime: startTime,
      endTime: endTime,
      addedTime: addedTime,
      duration: duration,
    );
    await _dbRef.set(newTrial.toMap());
  }

  Future<void> delete() async {
    await _dbRef.remove();
  }

  TimeTrial copyWith(
      {String? userName,
      DateTime? startTime,
      DateTime? endTime,
      Duration? addedTime,
      Duration? duration}) {
    return TimeTrial(
      id: id,
      carName: carName,
      userName: userName ?? this.userName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      addedTime: addedTime ?? this.addedTime,
      duration: duration ?? this.duration,
    );
  }
}
