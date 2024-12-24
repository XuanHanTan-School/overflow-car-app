import 'package:time_trial_api/time_trial_api.dart';

class TimeTrialState {
  final String? carName;
  TimeTrial? _currentTrial;

  TimeTrial? get currentTrial => _currentTrial;

  TimeTrialState({this.carName, TimeTrial? currentTrial})
      : _currentTrial = currentTrial;

  TimeTrialState copyWith({String? carName}) {
    return TimeTrialState(carName: carName ?? this.carName);
  }

  TimeTrialState copyWithCurrentTrial({TimeTrial? currentTrial}) {
    return copyWith().._currentTrial = currentTrial;
  }
}
