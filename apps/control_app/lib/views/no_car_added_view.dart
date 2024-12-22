import 'package:control_app/pages/add_car.dart';
import 'package:control_app/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoCarAddedView extends StatelessWidget {
  const NoCarAddedView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "No cars added",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(
          height: 30,
        ),
        const Text("Add a car or import settings to get started."),
        const SizedBox(
          height: 50,
        ),
        Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                await importCarsFromJson(context: context);
              },
              child: const Text("Import cars"),
            ),
            OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCarPage(),
                  ),
                );
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft
                ]);
              },
              child: const Text("Add car"),
            )
          ],
        )
      ],
    );
  }
}
