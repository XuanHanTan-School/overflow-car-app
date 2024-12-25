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
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CarBloc()..add(CarAppInitialize())),
        BlocProvider(
            create: (_) => TimeTrialBloc()..add(TimeTrialAppInitialize())),
      ],
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
  late final StreamSubscription carBlocSelectedCarStreamSubscription;

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

    final carBloc = context.read<CarBloc>();
    carBlocSelectedCarStreamSubscription = carBloc.stream
        .distinct((prev, current) =>
            prev.selectedCarIndex == current.selectedCarIndex)
        .listen((state) {
      if (!mounted) return;
      final timeTrialBloc = context.read<TimeTrialBloc>();
      final selectedCarIndex = state.selectedCarIndex;

      if (selectedCarIndex != null) {
        timeTrialBloc
            .add(SetCar(carName: state.currentCars[selectedCarIndex].name));
      } else {
        timeTrialBloc.add(SetCar(carName: null));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    orientationStreamSubscription.cancel();
    screenOrientationStreamSubscription.cancel();
    carBlocSelectedCarStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<CarBloc>(context)),
        BlocProvider.value(value: BlocProvider.of<TimeTrialBloc>(context)),
      ],
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
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
