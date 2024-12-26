import 'package:car_api/overflow_car.dart';

sealed class CarEvent {}

final class CarAppInitialize extends CarEvent {}

final class AddCar extends CarEvent {
  final String name;
  final String host;
  final int commandPort;
  final int videoPort;

  AddCar({
    required this.name,
    required this.host,
    required this.commandPort,
    required this.videoPort,
  });
}

final class ChangeSelectedCar extends CarEvent {
  final int selectedCarIndex;

  ChangeSelectedCar(this.selectedCarIndex);
}

final class ConnectSelectedCar extends CarEvent {}

final class UpdateDriveState extends CarEvent {
  final int? angle;
  final bool? forward;
  final bool? accelerate;

  UpdateDriveState({this.angle, this.forward, this.accelerate});
}

final class SendDriveCommand extends CarEvent {}

final class DisconnectSelectedCar extends CarEvent {}

final class DeleteCar extends CarEvent {
  final Car car;

  DeleteCar({required this.car});
}

final class EditPerformanceSettings extends CarEvent {
  final int? cacheMillis;
  final int? updateIntervalMillis;

  EditPerformanceSettings({this.cacheMillis, this.updateIntervalMillis});
}

final class ResetCarBloc extends CarEvent {}