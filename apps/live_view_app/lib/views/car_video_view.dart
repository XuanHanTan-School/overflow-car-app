import 'dart:async';

import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:car_bloc/car_state.dart';
import 'package:shared_car_components/pages/settings.dart';
import 'package:live_view_app/views/overlays/time_trial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class CarVideoView extends StatefulWidget {
  final CarState state;
  const CarVideoView({super.key, required this.state});

  @override
  State<CarVideoView> createState() => _CarVideoViewState();
}

class _CarVideoViewState extends State<CarVideoView> {
  Timer? showSettingsOverlayTimer;
  var isSettingsOverlayVisible = false;

  @override
  void dispose() {
    super.dispose();
    showSettingsOverlayTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    final videoZoom = mediaQuery.size.width /
        (mediaQuery.size.height *
            widget.state.currentCars[widget.state.selectedCarIndex!]
                .aspectRatioValue);

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
        Positioned.fill(child: TimeTrialOverlay()),
      ],
    );
  }
}
