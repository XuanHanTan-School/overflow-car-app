import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:control_app/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PerformanceManagementPage extends StatelessWidget {
  const PerformanceManagementPage({super.key});

  String? validateMs(String? numStr) {
    if (numStr == null || numStr == "") return null;

    final number = int.tryParse(numStr);
    if (number != null && number >= 1 && number <= 10000) {
      return null;
    }

    return "Enter a valid duration (1 to 10000)";
  }

  Future<void> restartConnection({required CarBloc carBloc}) async {
    carBloc.add(DisconnectSelectedCar());
    await carBloc.stream.firstWhere(
        (state) => state.connectionState == CarConnectionState.disconnected);
    carBloc.add(ConnectSelectedCar());
  }

  void updateCacheDuration(
      {required PerformanceSettings perfSettings,
      required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String cacheDurationStr = perfSettings.cacheMillis.toString();
        final cacheDurationController =
            TextEditingController(text: cacheDurationStr);
        final formKey = GlobalKey<FormState>();
        String? loadMsg;

        return StatefulBuilder(builder: (context, setStateDiag) {
          return AlertDialog(
            title: Text("Change video cache duration"),
            content: loadMsg != null
                ? SizedBox(
                    height: 200,
                    child: LoadingView(message: loadMsg!),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          """Overflow Car automatically creates a video buffer of the specified duration, making the video smoother during unstable network conditions.
                    
Decreasing the buffer will decrease latency, but a stable network connection is required."""),
                      const SizedBox(
                        height: 30,
                      ),
                      Form(
                        key: formKey,
                        child: Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                validator: validateMs,
                                controller: cacheDurationController,
                                decoration: InputDecoration(
                                  hintText: "100",
                                  label: Text("Cache duration"),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  formKey.currentState?.validate();
                                  setStateDiag(() {
                                    cacheDurationStr = value;
                                  });
                                },
                              ),
                            ),
                            Text("ms"),
                          ],
                        ),
                      ),
                    ],
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
                      onPressed: formKey.currentState?.validate() == true
                          ? () async {
                              setStateDiag(() {
                                loadMsg = "Restarting connection...";
                              });

                              final carBloc = context.read<CarBloc>();
                              var newCacheDuration = 100;
                              if (cacheDurationStr != "") {
                                newCacheDuration = int.parse(cacheDurationStr);
                              }

                              carBloc.add(EditPerformanceSettings(
                                  cacheMillis: newCacheDuration));
                              await carBloc.stream.firstWhere((state) =>
                                  state.perfSettings.cacheMillis ==
                                  newCacheDuration);
                              await restartConnection(carBloc: carBloc);

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            }
                          : null,
                      child: Text("Done"),
                    ),
                  ],
          );
        });
      },
    );
  }

  void updateCommandInterval(
      {required PerformanceSettings perfSettings,
      required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String commandIntervalStr =
            perfSettings.updateIntervalMillis.toString();
        final commandIntervalController =
            TextEditingController(text: commandIntervalStr);
        final formKey = GlobalKey<FormState>();
        String? loadMsg;

        return StatefulBuilder(builder: (context, setStateDiag) {
          return AlertDialog(
            title: Text("Change command update interval"),
            content: loadMsg != null
                ? SizedBox(
                    height: 200,
                    child: LoadingView(message: loadMsg!),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          """Overflow Car intelligently sends steering and pedal input to the car at intervals.
                    
Change the time between each update depending on the hardware and network capabilities of the car and the device."""),
                      const SizedBox(
                        height: 30,
                      ),
                      Form(
                        key: formKey,
                        child: Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                maxLines: 1,
                                validator: validateMs,
                                controller: commandIntervalController,
                                decoration: InputDecoration(
                                  hintText: "30",
                                  label: Text("Command update interval"),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  formKey.currentState?.validate();
                                  setStateDiag(() {
                                    commandIntervalStr = value;
                                  });
                                },
                              ),
                            ),
                            Text("ms"),
                          ],
                        ),
                      ),
                    ],
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
                      onPressed: formKey.currentState?.validate() == true
                          ? () async {
                              setStateDiag(() {
                                loadMsg = "Restarting connection...";
                              });

                              final carBloc = context.read<CarBloc>();
                              var newUpdateInterval = 30;
                              if (commandIntervalStr != "") {
                                newUpdateInterval =
                                    int.parse(commandIntervalStr);
                              }

                              carBloc.add(EditPerformanceSettings(
                                  updateIntervalMillis: newUpdateInterval));
                              await carBloc.stream.firstWhere((state) =>
                                  state.perfSettings.updateIntervalMillis ==
                                  newUpdateInterval);
                              await restartConnection(carBloc: carBloc);

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            }
                          : null,
                      child: Text("Done"),
                    ),
                  ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text("Performance"),
          ),
          body: SafeArea(
            child: BlocBuilder<CarBloc, CarState>(
              buildWhen: (previous, current) =>
                  previous.perfSettings != current.perfSettings,
              builder: (context, state) {
                final perfSettings = state.perfSettings;

                return ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.gamepad_outlined),
                      title: Text("Update command interval"),
                      subtitle: Text("${perfSettings.updateIntervalMillis}ms"),
                      onTap: () {
                        updateCommandInterval(
                            perfSettings: perfSettings, context: context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.videocam_outlined),
                      title: Text("Live video cache duration"),
                      subtitle: Text("${perfSettings.cacheMillis}ms"),
                      onTap: () {
                        updateCacheDuration(
                            perfSettings: perfSettings, context: context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
