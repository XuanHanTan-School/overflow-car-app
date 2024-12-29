import 'dart:async';

import 'package:car_management_bloc/car_management_event.dart';
import 'package:car_management_bloc/car_management_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage/local_storage.dart';
import 'package:car_api/overflow_car.dart';

class CarManagementBloc extends Bloc<CarManagementEvent, CarManagementState> {
  Timer? sendDriveCommandTimer;

  CarManagementBloc()
      : super(CarManagementState(
          isInitialized: false,
          currentCars: [],
        )) {
    on<CarAppInitialize>(onAppInitialize);
    on<AddCar>(onAddCar);
    on<DeleteCar>(onDeleteCar);
    on<ResetCarBloc>(onResetCarBloc);
  }

  Future<void> onAppInitialize(CarAppInitialize event, Emitter emit) async {
    final cars = await LocalStorage.getCars();
    emit(state.copyWith(isInitialized: true, currentCars: cars));
  }

  Future<void> onAddCar(AddCar event, Emitter emit) async {
    final car = Car(
      name: event.name,
      host: "",
      commandPort: 0,
      videoPort: 0,
      username: "",
      password: "",
    );

    if (state.currentCars.any((eachCar) => eachCar.name == car.name)) {
      emit(state.copyWith(
          currentCars: state.currentCars
                  .where((eachCar) => eachCar.name != car.name)
                  .toList() +
              [car]));
    } else {
      emit(state.copyWith(currentCars: state.currentCars + [car]));
    }

    await LocalStorage.storeCar(car);
  }

  Future<void> onDeleteCar(DeleteCar event, Emitter emit) async {
    await LocalStorage.removeCar(event.car);
    emit(
        state.copyWith(currentCars: [...state.currentCars]..remove(event.car)));
  }

  Future<void> onResetCarBloc(ResetCarBloc event, Emitter emit) async {
    await LocalStorage.clear();
    emit(CarManagementState(
      isInitialized: false,
      currentCars: [],
    ));
  }
}
