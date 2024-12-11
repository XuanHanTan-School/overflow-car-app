sealed class CarEvent {}

final class AppInitialize extends CarEvent {}

final class ChangeSelectedCar extends CarEvent {
  final int selectedCarIndex;

  ChangeSelectedCar(this.selectedCarIndex);
}

final class ConnectSelectedCar extends CarEvent {}

final class DisconnectSelectedCar extends CarEvent {}