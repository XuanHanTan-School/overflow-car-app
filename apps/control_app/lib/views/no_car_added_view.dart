import 'package:control_app/add_car.dart';
import 'package:flutter/material.dart';

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
    );
  }
}