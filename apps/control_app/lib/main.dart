import 'package:control_app/add_car.dart';
import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_event.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const HomePage());
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => CarBloc()..add(AppInitialize()),
      child: MaterialApp(
        home: Scaffold(
          body: BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              final currentCars = state.currentCars;
              final selectedCarIndex = state.selectedCarIndex;

              if (!state.isInitialized) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 30,
                    children: [
                      CircularProgressIndicator(),
                      Text(
                        "Initialising...",
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
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

              return Column(
                children: [],
              );
            },
          ),
        ),
      ),
    );
  }
}
