sealed class CarEvent {}

final class AppInitialize extends CarEvent {}

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
