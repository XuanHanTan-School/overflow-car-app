import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:car_bloc/car_state.dart';
import 'package:shared_car_components/views/loading_view.dart';
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

  void updateLowLatencyMode({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String? loadMsg;

        return StatefulBuilder(
          builder: (context, setStateDiag) => AlertDialog(
            title: Text("Change video latency"),
            content: loadMsg != null
                ? SizedBox(
                    height: 200,
                    child: LoadingView(message: loadMsg!),
                  )
                : SizedBox(
                    height: 250,
                    width: 400,
                    child: ListView(
                      children: [
                        Text(
                            """Increasing latency can help with video playback stability, especially on slower networks.
                            
Decreasing the latency will make the experience more responsive, but a stable network connection is required."""),
                        const SizedBox(
                          height: 30,
                        ),
                        BlocBuilder<CarBloc, CarState>(
                          buildWhen: (previous, current) =>
                              previous.perfSettings.lowLatency !=
                              current.perfSettings.lowLatency,
                          builder: (context, state) {
                            final perfSettings = state.perfSettings;

                            return SwitchListTile(
                              title: Text("Low-latency video"),
                              value: perfSettings.lowLatency,
                              onChanged: (newValue) async {
                                setStateDiag(() {
                                  loadMsg = "Updating settings...";
                                });

                                final carBloc = context.read<CarBloc>();

                                carBloc.add(EditPerformanceSettings(
                                    lowLatency: newValue));
                                await carBloc.stream.firstWhere((state) =>
                                    state.perfSettings.lowLatency == newValue);

                                if (carBloc.state.selectedCarIndex != null &&
                                    carBloc.state.connectionState ==
                                        CarConnectionState.connected) {
                                  setStateDiag(() {
                                    loadMsg = "Restarting connection...";
                                  });
                                  await restartConnection(carBloc: carBloc);
                                }

                                setStateDiag(() {
                                  loadMsg = null;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
            actions: loadMsg != null
                ? null
                : [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: Text("Done"),
                    ),
                  ],
          ),
        );
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

        return StatefulBuilder(
          builder: (context, setStateDiag) => AlertDialog(
            title: Text("Change command update interval"),
            content: loadMsg != null
                ? SizedBox(
                    height: 200,
                    child: LoadingView(message: loadMsg!),
                  )
                : SizedBox(
                    height: 250,
                    width: 400,
                    child: ListView(
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
                                loadMsg = "Updating settings...";
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

                              if (carBloc.state.selectedCarIndex != null &&
                                  carBloc.state.connectionState ==
                                      CarConnectionState.connected) {
                                setStateDiag(() {
                                  loadMsg = "Restarting connection...";
                                });
                                await restartConnection(carBloc: carBloc);
                              }

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);
                            }
                          : null,
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
    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: Scaffold(
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
                    title: Text("Low-latency video"),
                    subtitle:
                        Text(perfSettings.lowLatency ? "Enabled" : "Disabled"),
                    onTap: () {
                      updateLowLatencyMode(context: context);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
