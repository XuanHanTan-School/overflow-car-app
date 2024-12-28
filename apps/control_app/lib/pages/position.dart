import 'dart:async';

import 'package:app_utilities/app_utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class PositionPage extends StatefulWidget {
  final String userTrialId;

  const PositionPage({super.key, required this.userTrialId});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  late final StreamSubscription<TimeTrialState>? _timeTrialSubscription;

  @override
  void initState() {
    super.initState();

    var skipInitialCompleted = false;
    final timeTrialBloc = context.read<TimeTrialBloc>();
    _timeTrialSubscription = timeTrialBloc.stream.distinct((previous, current) {
      return previous.currentTrial?.id == null ||
          previous.currentTrial?.id == current.currentTrial?.id;
    }).listen((state) {
      if (!skipInitialCompleted) {
        skipInitialCompleted = true;
        return;
      }

      if (!mounted) return;
      Navigator.pop(context);
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
    final navigator = Navigator.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: BlocProvider.of<TimeTrialBloc>(context)
        ..add(RefreshLeaderboard(userTrialId: widget.userTrialId)),
      child: Scaffold(
        body: BlocBuilder<TimeTrialBloc, TimeTrialState>(
          buildWhen: (previous, current) {
            if (previous.leaderboard != current.leaderboard) {
              return true;
            }

            return false;
          },
          builder: (context, state) {
            if (state.playerPosition == null) {
              return LoadingView(message: "Loading position...");
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.yellow[isDark ? 300 : 700],
                    size: 96,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    toOrdinal(state.playerPosition! + 1),
                    style: theme.textTheme.headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text("Congratulations!"),
                  const SizedBox(
                    height: 40,
                  ),
                  FilledButton(
                    onPressed: () {
                      navigator.pop();
                    },
                    child: Text("Close"),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
