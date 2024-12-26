import 'dart:async';

import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_state.dart';
import 'package:live_view_app/views/car_video_view.dart';
import 'package:shared_car_components/views/car_disconnected_view.dart';
import 'package:shared_car_components/views/loading_view.dart';
import 'package:shared_car_components/views/no_car_added_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_trial_bloc/time_trial_bloc.dart';
import 'package:time_trial_bloc/time_trial_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamSubscription carBlocSelectedCarStreamSubscription;

  @override
  void initState() {
    super.initState();

    final carBloc = context.read<CarBloc>();
    carBlocSelectedCarStreamSubscription = carBloc.stream
        .distinct((prev, current) =>
            prev.selectedCarIndex == current.selectedCarIndex)
        .listen((state) {
      if (!mounted) return;
      final timeTrialBloc = context.read<TimeTrialBloc>();
      final selectedCarIndex = state.selectedCarIndex;

      if (selectedCarIndex != null) {
        timeTrialBloc
            .add(SetCar(carName: state.currentCars[selectedCarIndex].name));
      } else {
        timeTrialBloc.add(SetCar(carName: null));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    carBlocSelectedCarStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<CarBloc>(context)),
        BlocProvider.value(value: BlocProvider.of<TimeTrialBloc>(context)),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
              return Center(child: NoCarAddedView());
            }

            return Builder(
              builder: (context) {
                final currentCar = state.currentCars[selectedCarIndex];

                switch (state.connectionState) {
                  case CarConnectionState.disconnected:
                    return Center(
                      child: CarDisconnectedView(car: currentCar),
                    );
                  case CarConnectionState.connecting:
                    return LoadingView(message: "Connecting...");
                  case CarConnectionState.connected:
                    return CarVideoView(state: state);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
