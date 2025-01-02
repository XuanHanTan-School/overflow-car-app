import 'dart:async';

import 'package:car_bloc/car_event.dart';
import 'package:car_bloc/car_state.dart';
import 'package:car_bloc/utilities/media_kit_stub.dart'
    if (dart.library.io) 'package:car_bloc/utilities/media_kit_io.dart'
    if (dart.library.html) 'package:car_bloc/utilities/media_kit_web.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage/local_storage.dart';
import 'package:car_api/overflow_car.dart';
import 'package:media_kit/media_kit.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  Timer? sendDriveCommandTimer;

  CarBloc()
      : super(CarState(
          isInitialized: false,
          currentCars: [],
          perfSettings: PerformanceSettings(),
        )) {
    on<CarAppInitialize>(onAppInitialize);
    on<AddCar>(onAddCar);
    on<ChangeSelectedCar>(onChangeSelectedCar);
    on<ConnectSelectedCar>(onConnectSelectedCar);
    on<UpdateDriveState>(onUpdateDriveState);
    on<SendDriveCommand>(onSendDriveCommand);
    on<DisconnectSelectedCar>(onDisconnectSelectedCar);
    on<DeleteCar>(onDeleteCar);
    on<EditPerformanceSettings>(onEditPerformanceSettings);
    on<ResetCarBloc>(onResetCarBloc);
  }

  Future<void> onAppInitialize(CarAppInitialize event, Emitter emit) async {
    final perfSettings =
        PerformanceSettings.fromMap(await LocalStorage.getSettings());
    final cars = await LocalStorage.getCars();
    int? selectedCarIndex;

    if (cars.isNotEmpty) {
      selectedCarIndex = await LocalStorage.getSelectedCarIndex() ?? 0;
    }

    emit(state
        .copyWith(
            isInitialized: true, currentCars: cars, perfSettings: perfSettings)
        .copyWithSelectedCarIndex(selectedCarIndex: selectedCarIndex));

    if (cars.isNotEmpty) {
      await onConnectSelectedCar(ConnectSelectedCar(), emit);
    }
  }

  Future<void> onAddCar(AddCar event, Emitter emit) async {
    final car = Car(
      name: event.name,
      connectionMethod: event.connectionMethod,
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

    if (state.selectedCarIndex == null) {
      await onChangeSelectedCar(ChangeSelectedCar(0), emit);
      await onConnectSelectedCar(ConnectSelectedCar(), emit);
    }
  }

  Future<void> onChangeSelectedCar(
      ChangeSelectedCar event, Emitter emit) async {
    await LocalStorage.setSelectedCarIndex(event.selectedCarIndex);
    emit(state.copyWithSelectedCarIndex(
        selectedCarIndex: event.selectedCarIndex));
  }

  void checkCarSelected() {
    if (state.selectedCarIndex == null) {
      throw StateError(
          "No car has been selected yet. Add a car to connect to it.");
    }
  }

  Future<void> onConnectSelectedCar(
      ConnectSelectedCar event, Emitter emit) async {
    checkCarSelected();
    emit(state.copyWith(connectionState: CarConnectionState.connecting));
    final currentCar = state.currentCars[state.selectedCarIndex!];
    try {
      await currentCar.connect();

      final player = Player();
      configureLowLatencyPlayback(state.perfSettings.lowLatency,
          player: player);
      await player.open(Media(currentCar.connectionMethod.videoUrl));
      emit(await state
          .copyWith(connectionState: CarConnectionState.connected)
          .copyWithVideoPlayer(player: player));

      CarDrivingState? prevDriveState;
      sendDriveCommandTimer = Timer.periodic(
          Duration(milliseconds: state.perfSettings.updateIntervalMillis),
          (timer) {
        if (prevDriveState != state.drivingState) {
          add(SendDriveCommand());
          prevDriveState = state.drivingState;
        }
      });
    } catch (e) {
      print("Error connecting to car: $e");
      await Future.delayed(Duration(milliseconds: 100));
      emit(state.copyWith(connectionState: CarConnectionState.disconnected));
    }

    await for (var isConnected in currentCar.connectionState.stream) {
      if (!isConnected) {
        sendDriveCommandTimer?.cancel();
        sendDriveCommandTimer = null;
        emit(await state
            .copyWith(connectionState: CarConnectionState.disconnected)
            .copyWithVideoPlayer(player: null));
        break;
      }
    }
  }

  void onUpdateDriveState(UpdateDriveState event, Emitter emit) {
    emit(state.copyWith(
      drivingState: state.drivingState.copyWith(
        angle: event.angle,
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
  }

  Future<void> onDeleteCar(DeleteCar event, Emitter emit) async {
    if (state.selectedCarIndex != null &&
        state.currentCars[state.selectedCarIndex!] == event.car &&
        state.connectionState == CarConnectionState.connected) {
      await onDisconnectSelectedCar(DisconnectSelectedCar(), emit);
    }

    var newSelectedCarIndex = state.selectedCarIndex;

    if (state.currentCars.length - 1 <= (newSelectedCarIndex ?? 0)) {
      newSelectedCarIndex = state.currentCars.length - 2;

      if (newSelectedCarIndex < 0) {
        newSelectedCarIndex = null;
      }
    }

    await LocalStorage.setSelectedCarIndex(newSelectedCarIndex);
    await LocalStorage.removeCar(event.car);

    emit(state
        .copyWith(currentCars: [...state.currentCars]..remove(event.car))
        .copyWithSelectedCarIndex(selectedCarIndex: newSelectedCarIndex));
  }

  Future<void> onEditPerformanceSettings(
      EditPerformanceSettings event, Emitter emit) async {
    final newSettings = state.perfSettings.copyWith(
      lowLatency: event.lowLatency,
      updateIntervalMillis: event.updateIntervalMillis,
    );
    await LocalStorage.storeSettings(newSettings.toMap());
    emit(state.copyWith(perfSettings: newSettings));
  }

  Future<void> onResetCarBloc(ResetCarBloc event, Emitter emit) async {
    if (state.selectedCarIndex != null) {
      await onDisconnectSelectedCar(DisconnectSelectedCar(), emit);
    }
    await LocalStorage.clear();
    emit(CarState(
      isInitialized: false,
      currentCars: [],
      perfSettings: PerformanceSettings(),
    ));
  }
}
