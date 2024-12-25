import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:time_trial_api/time_trial_api.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class TimeTrialBloc extends Bloc<TimeTrialEvent, TimeTrialState> {
  BehaviorSubject<TimeTrial?>? _currentTimeTrialStreamController;
  StreamSubscription<TimeTrial>? _timeTrialUpdatesStreamSubscription;
  StreamSubscription<String>? _timeTrialDeletesStreamSubscription;

  TimeTrialBloc() : super(TimeTrialState()) {
    on<TimeTrialAppInitialize>(onAppInitialize);
    on<SetCar>(onSetCar);
  }

  Future<void> onAppInitialize(
      TimeTrialAppInitialize event, Emitter emit) async {
    await TimeTrialManager.startTimeTrialListeners();
  }

  Future<void> setupTimeTrialStreamController() async {
    await _timeTrialUpdatesStreamSubscription?.cancel();
    await _timeTrialDeletesStreamSubscription?.cancel();
    await _currentTimeTrialStreamController?.close();
    _currentTimeTrialStreamController = BehaviorSubject();

    _timeTrialUpdatesStreamSubscription =
        TimeTrialManager.getTimeTrialUpdates().listen((trial) {
      if (trial.carName != state.carName) return;

      _currentTimeTrialStreamController?.add(trial);
    });

    _timeTrialDeletesStreamSubscription =
        TimeTrialManager.getTimeTrialDeletes().listen((trialId) async {
      if (trialId != (_currentTimeTrialStreamController?.value)?.id) {
        return;
      }

      _currentTimeTrialStreamController?.add(null);
    });
  }

  Future<void> onSetCar(SetCar event, Emitter emit) async {
    emit(state.copyWithCarName(carName: event.carName));

    await setupTimeTrialStreamController();
    await for (final currentTrial
        in _currentTimeTrialStreamController!.stream) {
      emit(state.copyWithCurrentTrial(currentTrial: currentTrial));
    }
  }
}
