import 'package:collection/collection.dart';
import 'package:time_trial_api/time_trial_api.dart';

class TimeTrialState {
  String? _carName;
  TimeTrial? _currentTrial;
  List<LeaderboardTimeTrial> leaderboard;

  String? get carName => _carName;
  TimeTrial? get currentTrial => _currentTrial;
  int? get playerPosition {
    if (_currentTrial == null) return null;

    final matchingLeaderboardTrial = leaderboard.firstWhereOrNull((trial) => trial.id == _currentTrial!.id);
    return matchingLeaderboardTrial?.position;
  }

  TimeTrialState(
      {String? carName, TimeTrial? currentTrial, this.leaderboard = const []})
      : _carName = carName,
        _currentTrial = currentTrial;

  TimeTrialState copyWith({List<LeaderboardTimeTrial>? leaderboard}) {
    return TimeTrialState(
      carName: _carName,
      currentTrial: currentTrial,
      leaderboard: leaderboard ?? this.leaderboard,
    );
  }

  TimeTrialState copyWithCarName({String? carName}) {
    return copyWith().._carName = carName;
  }

  TimeTrialState copyWithCurrentTrial({TimeTrial? currentTrial}) {
    return copyWith().._currentTrial = currentTrial;
  }
}
