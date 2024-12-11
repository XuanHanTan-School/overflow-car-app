import 'package:control_app/bloc/car_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CarBloc(),
      child: MaterialApp(
        home: Scaffold(
          body: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
