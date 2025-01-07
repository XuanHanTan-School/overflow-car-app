import 'package:time_trial_api/time_trial_api.dart';

sealed class TimeTrialEvent {}

final class TimeTrialAppInitialize extends TimeTrialEvent {}

final class SetCar extends TimeTrialEvent {
  final String? carName;

  SetCar({required this.carName});
}

final class AddTimeTrial extends TimeTrialEvent {
  final String carName;

  AddTimeTrial({required this.carName});
}

final class SetCurrentTrial extends TimeTrialEvent {
  final TimeTrial currentTrial;

  SetCurrentTrial({required this.currentTrial});
}

final class UpdateCurrentTrial extends TimeTrialEvent {
  final String? userName;
  final DateTime? startTime;
  final Duration? addedTime;
  final DateTime? endTime;

  UpdateCurrentTrial({this.userName, this.startTime, this.addedTime, this.endTime});
}

final class DeleteTimeTrial extends TimeTrialEvent {
  final TimeTrial trial;

  DeleteTimeTrial({required this.trial});
}

final class ListenToLeaderboard extends TimeTrialEvent {}

final class RefreshLeaderboard extends TimeTrialEvent {
  final String userTrialId;

  RefreshLeaderboard({required this.userTrialId});
}

final class ResetTimeTrialBloc extends TimeTrialEvent {}
