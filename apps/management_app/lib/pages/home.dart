import 'package:car_management_bloc/car_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_app/pages/settings.dart';
import 'package:management_app/pages/trial_configuration.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:shared_car_components/widgets/leaderboard_item.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> addTimeTrial({required BuildContext context}) async {
    final carBloc = context.read<CarManagementBloc>();
    final currentCars = carBloc.state.currentCars;

    if (currentCars.isEmpty) {
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text("No cars added"),
          content: Text(
              "Time trials must be assigned to a car. Please add a car or import cars in the Settings page."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text("Close"),
            ),
          ],
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        var selectedCarName = currentCars.first.name;
        String? loadMsg;

        return StatefulBuilder(
          builder: (context, setStateDiag) => AlertDialog(
            title: Text("Create time trial"),
            content: loadMsg != null
                ? SizedBox(
                    height: 200,
                    child: LoadingView(message: loadMsg!),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: DropdownMenu(
                      width: 200,
                      initialSelection: selectedCarName,
                      dropdownMenuEntries: currentCars
                          .map((car) => DropdownMenuEntry(
                              value: car.name, label: car.name))
                          .toList(),
                      onSelected: (value) {
                        setStateDiag(() {
                          selectedCarName = value!;
                        });
                      },
                    ),
                  ),
            actions: loadMsg != null
                ? null
                : [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        setStateDiag(() {
                          loadMsg = "Creating time trial...";
                        });

                        final timeTrialBloc = context.read<TimeTrialBloc>();
                        timeTrialBloc
                            .add(AddTimeTrial(carName: selectedCarName));
                        await timeTrialBloc.stream.firstWhere((state) =>
                            state.currentTrial?.carName == selectedCarName);

                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TrialConfigurationPage()),
                        );
                      },
                      child: Text("Done"),
                    ),
                  ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: BlocProvider.of<TimeTrialBloc>(context)
        ..add(ListenToLeaderboard()),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Leaderboard"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              icon: Icon(Icons.settings_outlined),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await addTimeTrial(context: context);
          },
          label: Text("New time trial"),
          icon: Icon(Icons.add_outlined),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
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
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) {
                  final trial = state.leaderboard[index];

                  return Center(
                    child: LeaderboardItem(
                      trial: trial,
                      isManagementMode: true,
                      onManagementAction: (navigationPath) async {
                        final timeTrialBloc = context.read<TimeTrialBloc>();

                        switch (navigationPath) {
                          case OptionsNavigationPath.continueTrial:
                            timeTrialBloc
                                .add(SetCurrentTrial(currentTrial: trial));
                            await timeTrialBloc.stream.firstWhere(
                                (state) => state.currentTrial == trial);

                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TrialConfigurationPage()),
                            );
                            break;
                          case OptionsNavigationPath.deleteTrial:
                            timeTrialBloc.add(DeleteTimeTrial(trial: trial));
                            break;
                        }
                      },
                    ),
                  );
                },
                itemCount: state.leaderboard.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
