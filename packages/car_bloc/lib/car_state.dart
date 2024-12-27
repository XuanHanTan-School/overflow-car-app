import 'package:car_api/overflow_car.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CarState {
  final bool isInitialized;
  final List<Car> currentCars;
  int? _selectedCarIndex;
  final CarConnectionState connectionState;
  late final CarDrivingState drivingState;
  VideoController? _videoPlayerController;
  Player? _player;
  final PerformanceSettings perfSettings;

  int? get selectedCarIndex => _selectedCarIndex;
  VideoController? get videoPlayerController => _videoPlayerController;
  Player? get player => _player;

  CarState(
      {required this.isInitialized,
      required this.currentCars,
      int? selectedCarIndex,
      this.connectionState = CarConnectionState.disconnected,
      CarDrivingState? drivingState,
      VideoController? videoPlayerController,
      Player? player,
      required this.perfSettings}) {
    this.drivingState = drivingState ??
        CarDrivingState(angle: 0, forward: true, accelerate: false);
    _selectedCarIndex = selectedCarIndex;
    _videoPlayerController = videoPlayerController;
    _player = player;
  }

  CarState copyWith({
    bool? isInitialized,
    List<Car>? currentCars,
    CarConnectionState? connectionState,
    CarDrivingState? drivingState,
    PerformanceSettings? perfSettings,
  }) {
    return CarState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentCars: currentCars ?? this.currentCars,
      selectedCarIndex: _selectedCarIndex,
      connectionState: connectionState ?? this.connectionState,
      drivingState: drivingState ?? this.drivingState,
      videoPlayerController: _videoPlayerController,
      player: _player,
      perfSettings: perfSettings ?? this.perfSettings,
    );
  }

  CarState copyWithSelectedCarIndex({required int? selectedCarIndex}) {
    return copyWith().._selectedCarIndex = selectedCarIndex;
  }

  Future<CarState> copyWithVideoPlayer({
    required Player? player,
  }) async {
    VideoController? videoPlayerController;

    if (player == null) {
      try {
        await this.player?.dispose();
      } catch (e) {
        print("Error disposing player: $e");
      }
      videoPlayerController = null;
    } else {
      videoPlayerController = VideoController(player);
    }

    return copyWith()
      .._videoPlayerController = videoPlayerController
      .._player = player;
  }
}

enum CarConnectionState { disconnected, connecting, connected }

class CarDrivingState {
  final int angle;
  final bool forward;
  final bool accelerate;

  const CarDrivingState(
      {required this.angle, required this.forward, required this.accelerate});

  CarDrivingState copyWith({int? angle, bool? forward, bool? accelerate}) {
    return CarDrivingState(
      angle: angle ?? this.angle,
      forward: forward ?? this.forward,
      accelerate: accelerate ?? this.accelerate,
    );
  }

  Map<String, dynamic> toMap() {
    return {"angle": angle, "forward": forward, "accelerate": accelerate};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CarDrivingState &&
        other.angle == angle &&
        other.forward == forward &&
        other.accelerate == accelerate;
  }

  @override
  int get hashCode => "$angle-$forward-$accelerate".hashCode;
}

class PerformanceSettings {
  final bool lowLatency;
  final int updateIntervalMillis;

  const PerformanceSettings(
      {this.lowLatency = true, this.updateIntervalMillis = 30});

  factory PerformanceSettings.fromMap(Map<String, dynamic> map) {
    return PerformanceSettings(
      lowLatency: map["lowLatency"] ?? true,
      updateIntervalMillis: map["updateIntervalMillis"] ?? 30,
    );
  }

  PerformanceSettings copyWith({
    bool? lowLatency,
    int? updateIntervalMillis,
  }) {
    return PerformanceSettings(
      lowLatency: lowLatency ?? this.lowLatency,
      updateIntervalMillis: updateIntervalMillis ?? this.updateIntervalMillis,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "lowLatency": lowLatency,
      "updateIntervalMillis": updateIntervalMillis,
    };
  }
}
