import 'package:overflow_car_api/overflow_car.dart';

class CarState {
  final List<Car> currentCars;
  final int? selectedCarIndex;

  const CarState({required this.currentCars, this.selectedCarIndex});

  CarState copyWith({List<Car>? currentCars, required int? selectedCarIndex}) {
    return CarState(
      currentCars: currentCars ?? this.currentCars,
      selectedCarIndex: selectedCarIndex,
    );
  }
}
