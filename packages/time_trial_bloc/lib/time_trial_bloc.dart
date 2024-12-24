import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_trial_api/time_trial_api.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class TimeTrialBloc extends Bloc<TimeTrialEvent, TimeTrialState> {
  final StreamController<TimeTrial?> _currentTimeTrialStreamController = StreamController.broadcast();

  TimeTrialBloc() : super(TimeTrialState()) {
    on<AppInitialize>(onAppInitialize);
    on<SetCar>(onSetCar);
  }

  Future<void> onAppInitialize(AppInitialize event, Emitter emit) async {
    await TimeTrialManager.startTimeTrialListeners();

    TimeTrialManager.getTimeTrialUpdates().listen((trial) {
      if (trial.carName != state.carName) return;

      _currentTimeTrialStreamController.add(trial);
    });

    TimeTrialManager.getTimeTrialDeletes().listen((trialId) async {
      if (trialId != (await _currentTimeTrialStreamController.stream.last)?.id) return;

      _currentTimeTrialStreamController.add(null);
    });
  }

  void onSetCar(SetCar event, Emitter emit) {
    emit(state.copyWith(carName: event.carName));
  }
}