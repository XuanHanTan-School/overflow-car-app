import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:shared_car_components/widgets/elapsed_time_display.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:time_trial_bloc/time_trial_state.dart';

class TrialConfigurationPage extends StatefulWidget {
  const TrialConfigurationPage({super.key});

  @override
  State<TrialConfigurationPage> createState() => _TrialConfigurationPageState();
}

class _TrialConfigurationPageState extends State<TrialConfigurationPage> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Trial configuration"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close_outlined),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: BlocBuilder<TimeTrialBloc, TimeTrialState>(
            buildWhen: (previous, current) {
              return previous.currentTrial != current.currentTrial;
            },
            builder: (context, state) {
              final currentTrial = state.currentTrial;
              if (currentTrial == null) {
                return LoadingView(message: "Creating time trial...");
              }

              if (currentTrial.userName == null) {
                return Text(
                  "Waiting for name...",
                  style: theme.textTheme.displaySmall,
                );
              }

              if (currentTrial.startTime == null) {
                return Column(
                  spacing: 40,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Start the time trial when you are ready",
                      style: theme.textTheme.displaySmall,
                    ),
                    IconButton.filled(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              final timeTrialBloc =
                                  context.read<TimeTrialBloc>();
                              final startTime = DateTime.now();
                              timeTrialBloc.add(UpdateCurrentTrial(
                                  startTime: startTime,
                                  addedTime: Duration.zero));
                              await timeTrialBloc.stream.firstWhere((state) =>
                                  state.currentTrial!.startTime == startTime &&
                                  state.currentTrial!.addedTime ==
                                      Duration.zero);

                              setState(() {
                                isLoading = false;
                              });
                            },
                      icon: isLoading
                          ? CircularProgressIndicator()
                          : Icon(Icons.play_arrow_outlined),
                      iconSize: 48,
                    ),
                  ],
                );
              }

              if (currentTrial.endTime == null) {
                return Column(
                  spacing: 40,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElapsedTimeDisplay(
                      startTime: currentTrial.startTime!,
                      addedTime: currentTrial.addedTime!,
                      overlayMode: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [1, 3, 5].map((add) {
                        return IconButton.filledTonal(
                          onPressed: () async {
                            final timeTrialBloc = context.read<TimeTrialBloc>();
                            final newAddedTime = currentTrial.addedTime! +
                                Duration(seconds: add);
                            timeTrialBloc.add(
                                UpdateCurrentTrial(addedTime: newAddedTime));
                            await timeTrialBloc.stream.firstWhere((state) =>
                                state.currentTrial!.addedTime == newAddedTime);
                          },
                          icon: SizedBox(
                            width: 36,
                            height: 36,
                            child: Center(
                              child: Text(
                                "+$add",
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    IconButton.filled(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() {
                                isLoading = true;
                              });

                              final timeTrialBloc =
                                  context.read<TimeTrialBloc>();
                              final endTime = DateTime.now();
                              timeTrialBloc
                                  .add(UpdateCurrentTrial(endTime: endTime));
                              await timeTrialBloc.stream.firstWhere((state) =>
                                  state.currentTrial!.endTime == endTime);

                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                      icon: isLoading
                          ? CircularProgressIndicator()
                          : Icon(Icons.stop_outlined),
                      iconSize: 48,
                    )
                  ],
                );
              }

              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
