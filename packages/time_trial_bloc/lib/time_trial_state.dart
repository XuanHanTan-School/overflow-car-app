import 'package:time_trial_api/time_trial_api.dart';

class TimeTrialState {
  String? _carName;
  TimeTrial? _currentTrial;

  String? get carName => _carName;
  TimeTrial? get currentTrial => _currentTrial;

  TimeTrialState({String? carName, TimeTrial? currentTrial})
      : _carName = carName, _currentTrial = currentTrial;

  TimeTrialState copyWith() {
    return TimeTrialState(carName: _carName, currentTrial: currentTrial);
  }
  
  TimeTrialState copyWithCarName({String? carName}) {
    return copyWith().._carName = carName;
  }

  TimeTrialState copyWithCurrentTrial({TimeTrial? currentTrial}) {
    return copyWith().._currentTrial = currentTrial;
  }
}
