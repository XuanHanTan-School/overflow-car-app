import 'dart:async';

import 'package:control_app/utilities/utilities.dart';
import 'package:control_app/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  late final StreamSubscription<TimeTrialState>? _timeTrialSubscription;

  @override
  void initState() {
    super.initState();

    final timeTrialBloc = context.read<TimeTrialBloc>();
    _timeTrialSubscription = timeTrialBloc.stream.distinct((previous, current) {
      return previous.currentTrial == current.currentTrial;
    }).listen((state) {
      if (!mounted) return;
      Navigator.pop(context);
    });
  }

  @override
  void dispose() async {
    await _timeTrialSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: BlocProvider.of<TimeTrialBloc>(context)..add(RefreshLeaderboard()),
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          body: SafeArea(
            child: BlocBuilder<TimeTrialBloc, TimeTrialState>(
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
                        toOrdinal(state.playerPosition!),
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
                          Navigator.pop(context);
                        },
                        child: Text("Done"),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
