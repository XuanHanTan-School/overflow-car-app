import 'package:car_api/overflow_car.dart';
import 'package:car_bloc/car_state.dart';

sealed class CarEvent {}

final class CarAppInitialize extends CarEvent {}

final class AddCar extends CarEvent {
  final String name;
  final String host;
  final int commandPort;
  final int videoPort;
  final String username;
  final String password;

  AddCar({
    required this.name,
    required this.host,
    required this.commandPort,
    required this.videoPort,
    required this.username,
    required this.password,
  });
}

final class ChangeSelectedCar extends CarEvent {
  final int selectedCarIndex;

  ChangeSelectedCar(this.selectedCarIndex);
}

final class ConnectSelectedCar extends CarEvent {}

final class ChangeDriveSettings extends CarEvent {
  final SteeringMode? steeringMode;

  ChangeDriveSettings({this.steeringMode});
}

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
