import 'package:app_utilities/app_utilities.dart';
import 'package:flutter/material.dart';
import 'package:management_app/pages/home.dart';
import 'package:management_app/utilities/utilities.dart';

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
        const Text("Add a car or import cars to get started."),
        const SizedBox(
          height: 50,
        ),
        Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                await importCarsFromJson(
                    context: context, isManagementMode: true);
              },
              child: const Text("Import cars"),
            ),
            OutlinedButton(
              onPressed: () {
                addCar(context: context);
              },
              child: const Text("Add car"),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Text("Skip"),
            ),
          ],
        ),
      ],
    );
  }
}
