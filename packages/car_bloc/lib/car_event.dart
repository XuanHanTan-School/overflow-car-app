import 'package:car_api/overflow_car.dart';

sealed class CarEvent {}

final class CarAppInitialize extends CarEvent {}

final class AddCar extends CarEvent {
  final String name;
  final CarConnectionMethod connectionMethod;

  AddCar({
    required this.name,
    required this.connectionMethod,
  });
}

final class ChangeSelectedCar extends CarEvent {
  final int selectedCarIndex;

  ChangeSelectedCar(this.selectedCarIndex);
}

final class ConnectSelectedCar extends CarEvent {}

final class UpdateDriveState extends CarEvent {
  final int? angle;
  final int? accelerate;

  UpdateDriveState({this.angle, this.accelerate});
}

final class SendDriveCommand extends CarEvent {}

final class DisconnectSelectedCar extends CarEvent {}

final class DeleteCar extends CarEvent {
  final Car car;

  DeleteCar({required this.car});
}

final class EditPerformanceSettings extends CarEvent {
  final bool? lowLatency;
  final int? updateIntervalMillis;

  EditPerformanceSettings({this.lowLatency, this.updateIntervalMillis});
}

final class ResetCarBloc extends CarEvent {}
