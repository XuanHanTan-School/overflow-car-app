import 'dart:async';
import 'dart:math';

import 'package:control_app/add_car.dart';
import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:control_app/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_sensors/motion_sensors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  Timer? showSettingsOverlayTimer;
  var isSettingsOverlayVisible = false;
  late final StreamSubscription screenOrientationStreamSubscription;
  late final StreamSubscription orientationStreamSubscription;

  @override
  void initState() {
    super.initState();

    int? screenOrientationAngle;
    screenOrientationStreamSubscription = motionSensors.screenOrientation.listen((event) {
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
    showSettingsOverlayTimer?.cancel();
    orientationStreamSubscription.cancel();
    screenOrientationStreamSubscription.cancel();
  }

  Future<void> onPedalChanged(
      {required bool isForward, required bool isPressed}) async {
    final carBloc = context.read<CarBloc>();

    carBloc.add(UpdateDriveState(
      forward: isForward,
      accelerate: isPressed,
    ));

    await carBloc.stream.firstWhere(
      (state) =>
          state.drivingState.forward == isForward &&
          state.drivingState.accelerate == isPressed,
    );
    carBloc.add(SendDriveCommand());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: MaterialApp(
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No cars added",
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                          "Add a car or import settings to get started."),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () {},
                            child: const Text("Import settings"),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddCarPage(),
                                ),
                              );
                            },
                            child: const Text("Add car"),
                          )
                        ],
                      )
                    ],
                  ),
                );
              }

              return Builder(
                builder: (context) {
                  final currentCar = state.currentCars[selectedCarIndex];

                  switch (state.connectionState) {
                    case CarConnectionState.disconnected:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${currentCar.name} is disconnected",
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Text("Ensure that the car is powered on."),
                            const SizedBox(
                              height: 50,
                            ),
                            Row(
                              spacing: 16,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    context
                                        .read<CarBloc>()
                                        .add(ConnectSelectedCar());
                                  },
                                  child: const Text("Connect"),
                                ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text("Settings"),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    case CarConnectionState.connecting:
                      return LoadingView(message: "Connecting...");
                    case CarConnectionState.connected:
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              onDoubleTap: () {
                                showSettingsOverlayTimer?.cancel();
                                setState(() {
                                  isSettingsOverlayVisible = true;
                                });
                                showSettingsOverlayTimer =
                                    Timer(const Duration(seconds: 5), () {
                                  setState(() {
                                    isSettingsOverlayVisible = false;
                                  });
                                });
                              },
                              behavior: HitTestBehavior.translucent,
                              child: const SizedBox(),
                            ),
                          ),
                          Positioned(
                            left: mediaQuery.viewPadding.left + 30,
                            right: mediaQuery.viewPadding.right + 30,
                            top: mediaQuery.viewPadding.top + 30,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              opacity: isSettingsOverlayVisible ? 1 : 0,
                              child: IgnorePointer(
                                ignoring: !isSettingsOverlayVisible,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  spacing: 10,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        context
                                            .read<CarBloc>()
                                            .add(DisconnectSelectedCar());
                                        setState(() {
                                          isSettingsOverlayVisible = false;
                                        });
                                      },
                                      icon: Icon(Icons.link_off_outlined),
                                      iconSize: 24,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isSettingsOverlayVisible = false;
                                        });
                                      },
                                      icon: Icon(Icons.settings_outlined),
                                      iconSize: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: mediaQuery.viewPadding.left + 30,
                            right: mediaQuery.viewPadding.right + 30,
                            bottom: mediaQuery.viewPadding.bottom + 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  child: IconButton.filledTonal(
                                    onPressed: () {},
                                    icon: RotatedBox(
                                      quarterTurns: 1,
                                      child: Icon(Icons.forward), // Reverse
                                    ),
                                    iconSize: 56,
                                  ),
                                  onTapDown: (details) async {
                                    await onPedalChanged(
                                        isForward: false, isPressed: true);
                                  },
                                  onTapCancel: () async {
                                    await onPedalChanged(
                                        isForward: false, isPressed: false);
                                  },
                                ),
                                GestureDetector(
                                  child: IconButton.filledTonal(
                                    onPressed: () {},
                                    icon: RotatedBox(
                                      quarterTurns: 3,
                                      child: Icon(Icons.forward), // Forward
                                    ),
                                    iconSize: 56,
                                  ),
                                  onTapDown: (details) async {
                                    await onPedalChanged(
                                        isForward: true, isPressed: true);
                                  },
                                  onTapCancel: () async {
                                    await onPedalChanged(
                                        isForward: true, isPressed: false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
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
