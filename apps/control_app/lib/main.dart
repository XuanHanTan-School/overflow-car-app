import 'dart:async';
import 'dart:math';

import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:car_bloc/car_state.dart';
import 'package:control_app/firebase_options.dart';
import 'package:control_app/views/car_control_view.dart';
import 'package:control_app/views/car_disconnected_view.dart';
import 'package:control_app/views/loading_view.dart';
import 'package:control_app/views/no_car_added_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_sensors/motion_sensors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(BlocProvider(
      create: (_) => CarBloc()..add(AppInitialize()),
      child: const HomePage(),
    ));
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamSubscription screenOrientationStreamSubscription;
  late final StreamSubscription orientationStreamSubscription;

  @override
  void initState() {
    super.initState();

    int? screenOrientationAngle;
    screenOrientationStreamSubscription =
        motionSensors.screenOrientation.listen((event) {
      screenOrientationAngle = event.angle?.toInt();
    });
    orientationStreamSubscription = motionSensors.orientation.listen((event) {
      if (mounted) {
        var angle = min(max((event.pitch * 180 / pi).round(), -90), 90);
        if (screenOrientationAngle == -90) {
          angle *= -1;
        }
        context.read<CarBloc>().add(UpdateDriveState(angle: angle));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    orientationStreamSubscription.cancel();
    screenOrientationStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          body: BlocBuilder<CarBloc, CarState>(
            buildWhen: (previous, current) {
              if (previous.isInitialized != current.isInitialized) {
                return true;
              }

              if (previous.selectedCarIndex != current.selectedCarIndex) {
                return true;
              }

              if (previous.connectionState != current.connectionState) {
                return true;
              }

              return false;
            },
            builder: (context, state) {
              final selectedCarIndex = state.selectedCarIndex;

              if (!state.isInitialized) {
                return LoadingView(message: "Initialising...");
              }

              if (selectedCarIndex == null) {
                return Center(child: NoCarAddedView());
              }

              return Builder(
                builder: (context) {
                  final currentCar = state.currentCars[selectedCarIndex];

                  switch (state.connectionState) {
                    case CarConnectionState.disconnected:
                      return Center(
                        child: CarDisconnectedView(car: currentCar),
                      );
                    case CarConnectionState.connecting:
                      return LoadingView(message: "Connecting...");
                    case CarConnectionState.connected:
                      return CarControlView(state: state);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
