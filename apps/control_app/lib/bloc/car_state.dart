import 'package:overflow_car_api/overflow_car.dart';

class CarState {
  final bool isInitialized;
  final List<Car> currentCars;
  final int? selectedCarIndex;

  const CarState({required this.isInitialized, required this.currentCars, this.selectedCarIndex});

  CarState copyWith({bool? isInitialized, List<Car>? currentCars, required int? selectedCarIndex}) {
    return CarState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentCars: currentCars ?? this.currentCars,
      selectedCarIndex: selectedCarIndex,
    );
  }
}
