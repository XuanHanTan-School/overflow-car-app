import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/pages/settings/car_management.dart';
import 'package:shared_car_components/pages/settings/performance_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.directions_car_outlined),
              title: Text("Cars"),
              subtitle: Text("Edit, add and remove cars"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CarManagementPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.speed_outlined),
              title: Text("Performance"),
              subtitle: Text("Command update interval, video latency"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PerformanceManagementPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.restore_outlined),
              title: Text("Reset"),
              subtitle: Text("Restore default settings and removes all cars"),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    String? loadMsg;

                    return PopScope(
                      canPop: false,
                      child: StatefulBuilder(builder: (dialogContext, setStateDiag) {
                        return AlertDialog(
                          title: Text("Reset settings"),
                          content: loadMsg != null
                              ? SizedBox(
                                  height: 200,
                                  child: LoadingView(message: loadMsg!),
                                )
                              : Text(
                                  "All cars will be removed and you will have to configure the app again. Are you sure?"),
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
                                        loadMsg = "Resetting...";
                                      });

                                      final carBloc = context.read<CarBloc>();
                                      carBloc.add(ResetCarBloc());
                                      await carBloc.stream.firstWhere((state) =>
                                          state.isInitialized == false);
                                      carBloc.add(CarAppInitialize());

                                      if (!context.mounted) return;
                                      final timeTrialBloc =
                                          context.read<TimeTrialBloc>();
                                      timeTrialBloc.add(ResetTimeTrialBloc());
                                      await timeTrialBloc.stream.firstWhere(
                                          (state) => state.carName == null);
                                      timeTrialBloc
                                          .add(TimeTrialAppInitialize());

                                      if (!dialogContext.mounted) return;
                                      Navigator.pop(dialogContext);
                                    },
                                    child: Text(
                                      "Reset",
                                      style: theme.textTheme.labelLarge!
                                          .copyWith(
                                              color: theme.colorScheme.error),
                                    ),
                                  ),
                                ],
                        );
                      }),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
