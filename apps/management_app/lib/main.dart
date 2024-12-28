import 'package:car_management_bloc/car_management_bloc.dart';
import 'package:car_management_bloc/car_management_event.dart';
import 'package:car_management_bloc/car_management_state.dart';
import 'package:management_app/firebase_options.dart';
import 'package:management_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_app/views/no_car_added_view.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => CarManagementBloc()..add(CarAppInitialize())),
          BlocProvider(
              create: (_) => TimeTrialBloc()..add(TimeTrialAppInitialize())),
        ],
        child: MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          home: BlocBuilder<CarManagementBloc, CarManagementState>(
            buildWhen: (previous, current) =>
                previous.isInitialized != current.isInitialized ||
                previous.currentCars != current.currentCars,
            builder: (context, state) {
              if (!state.isInitialized) {
                return const LoadingView(message: "Initialising...");
              }

              if (state.currentCars.isEmpty) {
                return const NoCarAddedView();
              }

              return const HomePage();
            },
          ),
        ),
      ),
    );
  });
}
