import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage/local_storage.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  CarBloc() : super(CarState(currentCars: [])) {
    on<AppInitialize>(onAppInitialize);
    on<ChangeSelectedCar>(onChangeSelectedCar);
    on<ConnectSelectedCar>(onConnectSelectedCar);
  }

  void onAppInitialize(AppInitialize event, Emitter emit) async {
    final cars = await LocalStorage.getCars();
    int? selectedCarIndex;

    if (cars.isNotEmpty) {
      selectedCarIndex = await LocalStorage.getSelectedCarIndex() ?? 0;

      final currentCar = cars[selectedCarIndex];
      await currentCar.connect();
    }

    emit(state.copyWith(currentCars: cars, selectedCarIndex: selectedCarIndex));
  }

  void onChangeSelectedCar(ChangeSelectedCar event, Emitter emit) async {
    emit(state.copyWith(selectedCarIndex: event.selectedCarIndex));
  }

  void checkCarSelected() {
    if (state.selectedCarIndex == null) {
      throw StateError("No car has been selected yet. Add a car to connect to it.");
    }
  }

  void onConnectSelectedCar(ConnectSelectedCar event, Emitter emit) async {
    checkCarSelected();
    await state.currentCars[state.selectedCarIndex!].connect();
  }

  void onDisconnectSelectedCar(DisconnectSelectedCar event, Emitter emit) async {
    checkCarSelected();
    await state.currentCars[state.selectedCarIndex!].disconnect();
  }
}
