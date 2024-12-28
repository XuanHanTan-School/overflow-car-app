import 'package:app_utilities/app_utilities.dart';
import 'package:car_management_bloc/car_management_bloc.dart';
import 'package:car_management_bloc/car_management_event.dart';
import 'package:car_management_bloc/car_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_app/utilities/utilities.dart';

class CarManagementPage extends StatelessWidget {
  const CarManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: BlocProvider.of<CarManagementBloc>(context),
      child: Scaffold(
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
          onPressed: () async {
            addCar(context: context);
          },
          child: Icon(Icons.add_outlined),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.file_upload_outlined),
                title: Text("Import cars"),
                onTap: () async {
                  await importCarsFromJson(
                      context: context, isManagementMode: true);
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  "My cars",
                  style: theme.textTheme.labelMedium,
                ),
              ),
              BlocBuilder<CarManagementBloc, CarManagementState>(
                buildWhen: (previous, current) =>
                    previous.currentCars != current.currentCars,
                builder: (context, state) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final car = state.currentCars[index];

                      return ListTile(
                        title: Text(car.name),
                        trailing: IconButton(
                          onPressed: () {
                            final carBloc = context.read<CarManagementBloc>();
                            carBloc.add(DeleteCar(car: car));
                          },
                          icon: Icon(Icons.delete_outlined),
                        ),
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
    );
  }
}
