import 'dart:async';

import 'package:live_view_app/pages/position.dart';
import 'package:shared_car_components/widgets/elapsed_time_display.dart';
import 'package:shared_car_components/widgets/video_overlay_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class TimeTrialOverlay extends StatefulWidget {
  const TimeTrialOverlay({super.key});

  @override
  State<TimeTrialOverlay> createState() => _TimeTrialOverlayState();
}

class _TimeTrialOverlayState extends State<TimeTrialOverlay> {
  late final StreamSubscription<TimeTrialState>? _timeTrialSubscription;

  @override
  void initState() {
    super.initState();

    var skipInitialCompleted = false;
    final timeTrialBloc = context.read<TimeTrialBloc>();
    _timeTrialSubscription = timeTrialBloc.stream.distinct((previous, current) {
      return previous.currentTrial == null ||
          current.currentTrial?.endTime == null ||
          previous.currentTrial?.endTime == current.currentTrial?.endTime;
    }).listen((state) {
      if (!skipInitialCompleted) {
        skipInitialCompleted = true;
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PositionPage(
            userTrialId: state.currentTrial!.id,
          ),
        ),
      );
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _timeTrialSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return BlocProvider.value(
      value: context.read<TimeTrialBloc>(),
      child: BlocBuilder<TimeTrialBloc, TimeTrialState>(
        buildWhen: (previous, current) {
          if (previous.currentTrial != current.currentTrial) {
            return true;
          }

          return false;
        },
        builder: (context, state) {
          final currentTrial = state.currentTrial;
          if (currentTrial == null) {
            return const SizedBox();
          }

          if (currentTrial.userName == null) {
            return Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: Text(
                  "Waiting for name...",
                  style: theme.textTheme.displaySmall,
                ),
              ),
            );
          }

          if (currentTrial.startTime == null) {
            return Padding(
              padding: EdgeInsets.only(top: mediaQuery.viewPadding.top + 20),
              child: Column(
                children: [
                  VideoOverlayText(text: 'Waiting for time trial to start...')
                ],
              ),
            );
          }

          if (currentTrial.startTime != null && currentTrial.endTime == null) {
            return Padding(
              padding: EdgeInsets.only(top: mediaQuery.viewPadding.top + 20),
              child: ElapsedTimeDisplay(
                startTime: currentTrial.startTime!,
                addedTime: currentTrial.addedTime!,
              ),
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}
