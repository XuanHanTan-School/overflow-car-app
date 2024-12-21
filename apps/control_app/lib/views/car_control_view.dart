import 'dart:async';

import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class CarControlView extends StatefulWidget {
  final CarState state;
  const CarControlView({super.key, required this.state});

  @override
  State<CarControlView> createState() => _CarControlViewState();
}

class _CarControlViewState extends State<CarControlView> {
  Timer? showSettingsOverlayTimer;
  var isSettingsOverlayVisible = false;

  @override
  void dispose() {
    super.dispose();
    showSettingsOverlayTimer?.cancel();
  }

  Future<void> onPedalChanged(
      {required bool isForward, required bool isPressed}) async {
    final carBloc = context.read<CarBloc>();

    carBloc.add(UpdateDriveState(
      forward: isForward,
      accelerate: isPressed,
    ));

    await carBloc.stream.firstWhere(
      (state) =>
          state.drivingState.forward == isForward &&
          state.drivingState.accelerate == isPressed,
    );
    carBloc.add(SendDriveCommand());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final videoZoom =
        mediaQuery.size.width / (mediaQuery.size.height * (16 / 9));

    return Stack(
      children: [
        if (widget.state.videoPlayerController != null)
          Transform.scale(
            scale: videoZoom,
            child: VlcPlayer(
              controller: widget.state.videoPlayerController!,
              aspectRatio: mediaQuery.size.aspectRatio,
            ),
          ),
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: () {
              showSettingsOverlayTimer?.cancel();
              setState(() {
                isSettingsOverlayVisible = true;
              });
              showSettingsOverlayTimer = Timer(const Duration(seconds: 5), () {
                setState(() {
                  isSettingsOverlayVisible = false;
                });
              });
            },
            behavior: HitTestBehavior.translucent,
            child: const SizedBox(),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: mediaQuery.viewPadding.top + 10,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: isSettingsOverlayVisible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !isSettingsOverlayVisible,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 10,
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<CarBloc>().add(DisconnectSelectedCar());
                      setState(() {
                        isSettingsOverlayVisible = false;
                      });
                    },
                    icon: Icon(Icons.link_off_outlined),
                    iconSize: 24,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isSettingsOverlayVisible = false;
                      });
                    },
                    icon: Icon(Icons.settings_outlined),
                    iconSize: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 30,
          right: 30,
          bottom: mediaQuery.viewPadding.bottom + 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: IconButton.filledTonal(
                  onPressed: () {},
                  icon: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(Icons.forward), // Reverse
                  ),
                  iconSize: 56,
                ),
                onTapDown: (details) async {
                  await onPedalChanged(isForward: false, isPressed: true);
                },
                onTapCancel: () async {
                  await onPedalChanged(isForward: false, isPressed: false);
                },
              ),
              GestureDetector(
                child: IconButton.filledTonal(
                  onPressed: () {},
                  icon: RotatedBox(
                    quarterTurns: 3,
                    child: Icon(Icons.forward), // Forward
                  ),
                  iconSize: 56,
                ),
                onTapDown: (details) async {
                  await onPedalChanged(isForward: true, isPressed: true);
                },
                onTapCancel: () async {
                  await onPedalChanged(isForward: true, isPressed: false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
