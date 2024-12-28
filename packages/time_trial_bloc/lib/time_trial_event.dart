sealed class TimeTrialEvent {}

final class TimeTrialAppInitialize extends TimeTrialEvent {}

final class SetCar extends TimeTrialEvent {
  final String? carName;

  SetCar({required this.carName});
}

final class UpdateCurrentTrial extends TimeTrialEvent {
  final String? userName;
  final DateTime? startTime;
  final DateTime? endTime;

  UpdateCurrentTrial({this.userName, this.startTime, this.endTime});
}

final class RefreshLeaderboard extends TimeTrialEvent {
  final String userTrialId;

  RefreshLeaderboard({required this.userTrialId});
}

final class ResetTimeTrialBloc extends TimeTrialEvent {}
