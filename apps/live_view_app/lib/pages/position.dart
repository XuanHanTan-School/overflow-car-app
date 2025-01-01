import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:shared_car_components/widgets/leaderboard_item.dart';
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
  late final Timer _autoCloseTimer;

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

    _autoCloseTimer = Timer(Duration(seconds: 30), () {
      if (!mounted) return;
      Navigator.pop(context);
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _timeTrialSubscription?.cancel();
    _autoCloseTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLargeScreen = mediaQuery.size.shortestSide > 600;

    return BlocProvider.value(
      value: BlocProvider.of<TimeTrialBloc>(context)
        ..add(RefreshLeaderboard(userTrialId: widget.userTrialId)),
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

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          LeaderboardTimeTrial? previousTrial;
                          final trial = state.leaderboard[index];
                          if (index > 0) {
                            previousTrial = state.leaderboard[index - 1];
                          }

                          return LeaderboardItem(
                            trial: trial,
                            previousTrial: previousTrial,
                            userTrialId: widget.userTrialId,
                          );
                        },
                        itemCount: state.leaderboard.length,
                      ),
                    ),
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
