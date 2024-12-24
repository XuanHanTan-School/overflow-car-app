sealed class TimeTrialEvent {}

final class TimeTrialAppInitialize extends TimeTrialEvent {}

final class SetCar extends TimeTrialEvent {
  final String? carName;

  SetCar({required this.carName});
}
