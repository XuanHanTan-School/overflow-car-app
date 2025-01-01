import 'dart:async';

import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:car_bloc/car_state.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_car_components/pages/settings.dart';
import 'package:control_app/views/overlays/time_trial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void onPedalChanged({required int amount}) {
    final carBloc = context.read<CarBloc>();

    carBloc.add(UpdateDriveState(
      accelerate: amount,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Text(
                "Waiting for video stream...",
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        if (widget.state.videoPlayerController != null)
          Positioned.fill(
            child: Video(
              controller: widget.state.videoPlayerController!,
              controls: NoVideoControls,
              fit: BoxFit.cover,
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
                    onPressed: () async {
                      setState(() {
                        isSettingsOverlayVisible = false;
                      });
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()));
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft
                      ]);
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
          right: 70,
          bottom: mediaQuery.viewPadding.bottom + 50,
          child: Joystick(
            base: JoystickBase(
              arrowsDecoration: JoystickArrowsDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                enableAnimation: false,
              ),
              decoration: JoystickBaseDecoration(
                color:
                    theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
                drawOuterCircle: false,
                drawArrows: true,
                boxShadows: [],
              ),
              mode: JoystickMode.vertical,
            ),
            period: const Duration(milliseconds: 30),
            stick: JoystickStick(
              decoration: JoystickStickDecoration(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            includeInitialAnimation: false,
            mode: JoystickMode.vertical,
            listener: (details) {
              onPedalChanged(amount: (details.y * -100).round());
            },
          ),
        ),
        Positioned.fill(child: TimeTrialOverlay()),
      ],
    );
  }
}
