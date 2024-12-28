import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:control_app/firebase_options.dart';
import 'package:control_app/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';
import 'package:shared_car_components/ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const HomePage(),
      ),
    ));
  });
}
