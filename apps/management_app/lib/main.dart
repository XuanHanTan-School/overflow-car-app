import 'package:car_management_bloc/car_management_bloc.dart';
import 'package:car_management_bloc/car_management_event.dart';
import 'package:management_app/firebase_options.dart';
import 'package:management_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => CarManagementBloc()..add(CarAppInitialize())),
        BlocProvider(
            create: (_) => TimeTrialBloc()..add(TimeTrialAppInitialize())),
      ],
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: const HomePage(),
      ),
    ));
  });
}
