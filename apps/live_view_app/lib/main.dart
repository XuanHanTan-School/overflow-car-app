import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:live_view_app/firebase_options.dart';
import 'package:live_view_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: const HomePage(),
      ),
    ));
  });
}
