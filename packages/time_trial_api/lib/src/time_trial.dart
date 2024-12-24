import 'package:firebase_database/firebase_database.dart';

class TimeTrial {
  final String id;
  final String? userName;
  final DateTime? startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String carName;

  DatabaseReference get _dbRef =>
      FirebaseDatabase.instance.ref("trials").child(id);

  const TimeTrial({
    required this.id,
    this.userName,
    this.startTime,
    this.endTime,
    this.duration,
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
      carName: map["carName"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userName": userName,
      "startTime": startTime?.millisecondsSinceEpoch,
      "endTime": endTime?.millisecondsSinceEpoch,
      "duration": duration?.inMilliseconds,
      "carName": carName,
    };
  }

  Future<void> update(
      {String? userName,
      DateTime? startTime,
      DateTime? endTime,
      Duration? duration}) async {
    final newTrial = copyWith(
      userName: userName,
      startTime: startTime,
      endTime: endTime,
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
      Duration? duration}) {
    return TimeTrial(
      id: id,
      carName: carName,
      userName: userName ?? this.userName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
    );
  }
}
