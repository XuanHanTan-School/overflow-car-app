import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage/local_storage.dart';
import 'package:overflow_car_api/overflow_car.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  CarBloc() : super(CarState(isInitialized: false, currentCars: [])) {
    on<AppInitialize>(onAppInitialize);
    on<AddCar>(onAddCar);
    on<ChangeSelectedCar>(onChangeSelectedCar);
    on<ConnectSelectedCar>(onConnectSelectedCar);
    on<UpdateDriveState>(onUpdateDriveState);
    on<SendDriveCommand>(onSendDriveCommand);
    on<DisconnectSelectedCar>(onDisconnectSelectedCar);
  }

  Future<void> onAppInitialize(AppInitialize event, Emitter emit) async {
    final cars = await LocalStorage.getCars();
    int? selectedCarIndex;

    if (cars.isNotEmpty) {
      selectedCarIndex = await LocalStorage.getSelectedCarIndex() ?? 0;
    }

    emit(state.copyWith(
        isInitialized: true,
        currentCars: cars,
        selectedCarIndex: selectedCarIndex));

    if (cars.isNotEmpty) {
      await onConnectSelectedCar(ConnectSelectedCar(), emit);
    }
  }

  Future<void> onAddCar(AddCar event, Emitter emit) async {
    final car = Car(
      name: event.name,
      host: event.host,
      commandPort: event.commandPort,
      videoPort: event.videoPort,
    );

    await LocalStorage.storeCar(car);

    emit(state.copyWith(
      currentCars: state.currentCars + [car],
      selectedCarIndex: state.selectedCarIndex,
    ));

    if (state.selectedCarIndex == null) {
      onChangeSelectedCar(ChangeSelectedCar(0), emit);
      onConnectSelectedCar(ConnectSelectedCar(), emit);
    }
  }

  void onChangeSelectedCar(ChangeSelectedCar event, Emitter emit) {
    emit(state.copyWith(selectedCarIndex: event.selectedCarIndex));
  }

  void checkCarSelected() {
    if (state.selectedCarIndex == null) {
      throw StateError(
          "No car has been selected yet. Add a car to connect to it.");
    }
  }

  Future<void> onConnectSelectedCar(ConnectSelectedCar event, Emitter emit) async {
    checkCarSelected();
    emit(state.copyWith(
        selectedCarIndex: state.selectedCarIndex,
        connectionState: CarConnectionState.connecting));
    final currentCar = state.currentCars[state.selectedCarIndex!];
    try {
      await currentCar.connect();
      emit(state.copyWith(
          selectedCarIndex: state.selectedCarIndex,
          connectionState: CarConnectionState.connected));
    } catch (e) {
      emit(state.copyWith(
          selectedCarIndex: state.selectedCarIndex,
          connectionState: CarConnectionState.disconnected));
    }

    await for (var isConnected in currentCar.connectionState.stream) {
      if (!isConnected) {
        emit(state.copyWith(
          selectedCarIndex: state.selectedCarIndex,
          connectionState: CarConnectionState.disconnected));
        break;
      }
    }
  }

  void onUpdateDriveState(UpdateDriveState event, Emitter emit) {
    checkCarSelected();
    emit(state.copyWith(
      selectedCarIndex: state.selectedCarIndex,
      drivingState: state.drivingState.copyWith(
        angle: event.angle,
        forward: event.forward,
        accelerate: event.accelerate,
      ),
    ));
  }

  void onSendDriveCommand(SendDriveCommand event, Emitter emit) {
    checkCarSelected();
    state.currentCars[state.selectedCarIndex!].sendCommand(Command(
      type: CommandType.drive,
      data: state.drivingState.toMap(),
    ));
  }

  Future<void> onDisconnectSelectedCar(
      DisconnectSelectedCar event, Emitter emit) async {
    checkCarSelected();
    await state.currentCars[state.selectedCarIndex!].disconnect();
    emit(state.copyWith(
        selectedCarIndex: state.selectedCarIndex,
        connectionState: CarConnectionState.disconnected));
  }
}
