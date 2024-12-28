import 'package:app_utilities/app_utilities.dart';
import 'package:flutter/material.dart';
import 'package:time_trial_api/time_trial_api.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardTimeTrial? previousTrial;
  final LeaderboardTimeTrial trial;
  final String? userTrialId;

  const LeaderboardItem({super.key, required this.trial, this.previousTrial, this.userTrialId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final previousPlayerSeparated =
        previousTrial != null && trial.position - previousTrial!.position > 1;
    final isPlayer = trial.id == userTrialId;

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
                              ? theme.textTheme.headlineMedium!.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : theme.textTheme.headlineSmall!.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
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
                    trial.userName ?? "N/A",
                    style: isPlayer
                        ? theme.textTheme.headlineMedium!.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : theme.textTheme.headlineSmall!.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
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
                              ? theme.textTheme.bodyLarge!.copyWith(
                                  fontSize: 18,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
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
  }
}
