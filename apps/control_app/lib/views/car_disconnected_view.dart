import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overflow_car_api/overflow_car.dart';

class CarDisconnectedView extends StatelessWidget {
  final Car car;

  const CarDisconnectedView({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${car.name} is disconnected",
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
                context.read<CarBloc>().add(ConnectSelectedCar());
              },
              child: const Text("Connect"),
            ),
            OutlinedButton(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft
                ]);
              },
              child: const Text("Settings"),
            )
          ],
        )
      ],
    );
  }
}
