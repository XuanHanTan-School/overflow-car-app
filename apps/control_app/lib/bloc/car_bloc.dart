import 'dart:async';

import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:local_storage/local_storage.dart';
import 'package:overflow_car_api/overflow_car.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  Timer? sendDriveCommandTimer;

  CarBloc() : super(CarState(isInitialized: false, currentCars: [])) {
    on<AppInitialize>(onAppInitialize);
    on<AddCar>(onAddCar);
    on<ChangeSelectedCar>(onChangeSelectedCar);
    on<ConnectSelectedCar>(onConnectSelectedCar);
    on<UpdateDriveState>(onUpdateDriveState);
    on<SendDriveCommand>(onSendDriveCommand);
    on<DisconnectSelectedCar>(onDisconnectSelectedCar);
    on<DeleteCar>(onDeleteCar);
  }

  Future<void> onAppInitialize(AppInitialize event, Emitter emit) async {
    final cars = await LocalStorage.getCars();
    int? selectedCarIndex;

    if (cars.isNotEmpty) {
      selectedCarIndex = await LocalStorage.getSelectedCarIndex() ?? 0;
    }

    emit(state
        .copyWith(isInitialized: true, currentCars: cars)
        .copyWithSelectedCarIndex(selectedCarIndex: selectedCarIndex));

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

      final videoPlayerController = VlcPlayerController.network(
        "rtsp://${currentCar.host}:${currentCar.videoPort}/video_stream",
        options: VlcPlayerOptions(rtp: VlcRtpOptions([":network-caching=100"])),
      );
      emit(await state
          .copyWith(connectionState: CarConnectionState.connected)
          .copyWithVideoPlayerController(
              videoPlayerController: videoPlayerController));

      CarDrivingState? prevDriveState;
      sendDriveCommandTimer =
          Timer.periodic(Duration(milliseconds: 30), (timer) {
        if (prevDriveState != state.drivingState) {
          add(SendDriveCommand());
          prevDriveState = state.drivingState;
        }
      });
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 100));
      emit(state.copyWith(connectionState: CarConnectionState.disconnected));
    }

    await for (var isConnected in currentCar.connectionState.stream) {
      if (!isConnected) {
        sendDriveCommandTimer?.cancel();
        sendDriveCommandTimer = null;
        emit(await state
            .copyWith(connectionState: CarConnectionState.disconnected)
            .copyWithVideoPlayerController(videoPlayerController: null));
        break;
      }
    }
  }

  void onUpdateDriveState(UpdateDriveState event, Emitter emit) {
    emit(state.copyWith(
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
  }

  Future<void> onDeleteCar(DeleteCar event, Emitter emit) async {
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
}
