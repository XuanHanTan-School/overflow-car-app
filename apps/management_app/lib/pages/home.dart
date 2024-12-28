import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/widgets/leaderboard_item.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isLargeScreen = mediaQuery.size.shortestSide > 600;

    return BlocProvider.value(
      value: BlocProvider.of<TimeTrialBloc>(context)
        ..add(ListenToLeaderboard()),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Leaderboard"),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Open settings page
              },
              icon: Icon(Icons.settings_outlined),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Create new time trial
          },
          label: Text("New time trial"),
          icon: Icon(Icons.add_outlined),
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
              if (state.leaderboard.isEmpty) {
                return Center(
                  child: Text(
                    "No time trials yet.",
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                itemBuilder: (context, index) => Center(
                  child: LeaderboardItem(
                    trial: state.leaderboard[index],
                  ),
                ),
                itemCount: state.leaderboard.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
