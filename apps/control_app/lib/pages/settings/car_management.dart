import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarManagementPage extends StatelessWidget {
  const CarManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text("Cars"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.add_outlined),
          ),
          body: SafeArea(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.file_upload_outlined),
                  title: Text("Import cars"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    "My cars",
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                BlocBuilder<CarBloc, CarState>(
                  buildWhen: (previous, current) {
                    if (previous.currentCars != current.currentCars) {
                      return true;
                    }

                    if (previous.selectedCarIndex != current.selectedCarIndex) {
                      return true;
                    }

                    return false;
                  },
                  builder: (context, state) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final car = state.currentCars[index];

                        return ListTile(
                          title: Text(car.name),
                          trailing: state.selectedCarIndex == index
                              ? Icon(Icons.check_outlined, color: Colors.green[theme.brightness == Brightness.light ? 700: 300],)
                              : null,
                        );
                      },
                      itemCount: state.currentCars.length,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
