import 'package:car_api/overflow_car.dart';

class CarManagementState {
  final bool isInitialized;
  final List<Car> currentCars;

  CarManagementState({
    required this.isInitialized,
    required this.currentCars,
  });

  CarManagementState copyWith({
    bool? isInitialized,
    List<Car>? currentCars,
  }) {
    return CarManagementState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentCars: currentCars ?? this.currentCars,
    );
  }
}
