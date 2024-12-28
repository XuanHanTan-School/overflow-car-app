import 'package:car_api/overflow_car.dart';

sealed class CarManagementEvent {}

final class CarAppInitialize extends CarManagementEvent {}

final class AddCar extends CarManagementEvent {
  final String name;

  AddCar({required this.name});
}

final class DeleteCar extends CarManagementEvent {
  final Car car;

  DeleteCar({required this.car});
}

final class ResetCarBloc extends CarManagementEvent {}
