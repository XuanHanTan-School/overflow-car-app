import 'dart:async';

import 'package:app_utilities/app_utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:time_trial_api/time_trial_api.dart';
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

    // TODO: Add auto close in 30s
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
    final mediaQuery = MediaQuery.of(context);
    final isLargeScreen = mediaQuery.size.shortestSide > 600;

    return BlocProvider.value(
      value: BlocProvider.of<TimeTrialBloc>(context)..add(RefreshLeaderboard(userTrialId: widget.userTrialId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Leaderboard"),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16)
              .copyWith(bottom: 16 + (isLargeScreen ? 16 : 0)),
          child: BlocBuilder<TimeTrialBloc, TimeTrialState>(
            buildWhen: (previous, current) {
              if (previous.leaderboard != current.leaderboard) {
                return true;
              }

              return false;
            },
            builder: (context, state) {
              if (state.playerPosition == null) {
                return LoadingView(message: "Loading...");
              }

              // TODO: Use leaderboard item
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        LeaderboardTimeTrial? previousTrial;
                        final trial = state.leaderboard[index];
                        if (index > 0) {
                          previousTrial = state.leaderboard[index - 1];
                        }

                        final previousPlayerSeparated = previousTrial != null &&
                            trial.position - previousTrial.position > 1;
                        final isPlayer = trial.id == widget.userTrialId;

                        final elapsedTimeString = trial.duration != null
                            ? generateElapsedTimeString(trial.duration!)
                            : "N/A";

                        return Column(
                          children: [
                            if (previousPlayerSeparated)
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                width: 450,
                                child: Divider(),
                              ),
                            SizedBox(
                              width: isPlayer ? 550 : 450,
                              child: Card(
                                color: isPlayer
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.secondaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              (trial.position + 1).toString(),
                                              style: isPlayer
                                                  ? theme
                                                      .textTheme.headlineMedium!
                                                      .copyWith(
                                                      color: theme.colorScheme
                                                          .onPrimaryContainer,
                                                    )
                                                  : theme
                                                      .textTheme.headlineSmall!
                                                      .copyWith(
                                                      color: theme.colorScheme
                                                          .onSecondaryContainer,
                                                    ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        trial.userName ?? "",
                                        style: isPlayer
                                            ? theme.textTheme.headlineMedium!
                                                .copyWith(
                                                color: theme.colorScheme
                                                    .onPrimaryContainer,
                                              )
                                            : theme.textTheme.headlineSmall!
                                                .copyWith(
                                                color: theme.colorScheme
                                                    .onSecondaryContainer,
                                              ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Spacer(),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              elapsedTimeString,
                                              style: isPlayer
                                                  ? theme.textTheme.bodyLarge!
                                                      .copyWith(
                                                      fontSize: 18,
                                                      color: theme.colorScheme
                                                          .onPrimaryContainer,
                                                    )
                                                  : theme.textTheme.bodyLarge!
                                                      .copyWith(
                                                      color: theme.colorScheme
                                                          .onSecondaryContainer,
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      },
                      itemCount: state.leaderboard.length,
                    ),
                    Spacer(),
                    const SizedBox(
                      height: 40,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        navigator.pop();
                      },
                      child: Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
