import 'package:overflow_car_api/overflow_car.dart';

class CarState {
  final bool isInitialized;
  final List<Car> currentCars;
  final int? selectedCarIndex;
  final CarConnectionState connectionState;

  const CarState(
      {required this.isInitialized,
      required this.currentCars,
      this.selectedCarIndex,
      this.connectionState = CarConnectionState.disconnected});

  CarState copyWith(
      {bool? isInitialized,
      List<Car>? currentCars,
      required int? selectedCarIndex,
      CarConnectionState? connectionState}) {
    return CarState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentCars: currentCars ?? this.currentCars,
      selectedCarIndex: selectedCarIndex,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}

enum CarConnectionState { disconnected, connecting, connected }
