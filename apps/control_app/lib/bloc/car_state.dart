import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:overflow_car_api/overflow_car.dart';

class CarState {
  final bool isInitialized;
  final List<Car> currentCars;
  int? _selectedCarIndex;
  final CarConnectionState connectionState;
  late final CarDrivingState drivingState;
  VlcPlayerController? _videoPlayerController;

  int? get selectedCarIndex => _selectedCarIndex;
  VlcPlayerController? get videoPlayerController => _videoPlayerController;

  CarState(
      {required this.isInitialized,
      required this.currentCars,
      int? selectedCarIndex,
      this.connectionState = CarConnectionState.disconnected,
      CarDrivingState? drivingState,
      VlcPlayerController? videoPlayerController}) {
    this.drivingState = drivingState ??
        CarDrivingState(angle: 0, forward: true, accelerate: false);
    _selectedCarIndex = selectedCarIndex;
    _videoPlayerController = videoPlayerController;
  }

  CarState copyWith({
    bool? isInitialized,
    List<Car>? currentCars,
    CarConnectionState? connectionState,
    CarDrivingState? drivingState,
  }) {
    return CarState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentCars: currentCars ?? this.currentCars,
      selectedCarIndex: _selectedCarIndex,
      connectionState: connectionState ?? this.connectionState,
      drivingState: drivingState ?? this.drivingState,
      videoPlayerController: _videoPlayerController,
    );
  }

  CarState copyWithSelectedCarIndex({required int? selectedCarIndex}) {
    return copyWith().._selectedCarIndex = selectedCarIndex;
  }

  Future<CarState> copyWithVideoPlayerController({
    required VlcPlayerController? videoPlayerController,
  }) async {
    if (videoPlayerController == null) {
      await _videoPlayerController?.dispose();
    }
    return copyWith().._videoPlayerController = videoPlayerController;
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
