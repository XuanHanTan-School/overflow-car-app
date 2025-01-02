import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_api/overflow_car.dart';

class CarInfoPage extends StatelessWidget {
  final Car car;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CarInfoPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReverseProxy =
        car.connectionMethod is CarConnectionMethodReverseProxy;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(car.name),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  final carBloc = context.read<CarBloc>();
                  final currentCars = carBloc.state.currentCars;
                  if (currentCars.contains(car)) {
                    carBloc.add(ChangeSelectedCar(currentCars.indexOf(car)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${car.name} has been selected."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.check_outlined),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                isReverseProxy
                    ? (car.connectionMethod as CarConnectionMethodReverseProxy)
                        .proxyUrl
                    : (car.connectionMethod as CarConnectionMethodDirect).host,
                style: theme.textTheme.displayMedium,
              ),
            ),
            if (!isReverseProxy)
              Builder(
                builder: (context) {
                  final connectionMethod =
                      car.connectionMethod as CarConnectionMethodDirect;

                  return Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: Text("Command port"),
                        subtitle: Text(connectionMethod.commandPort.toString()),
                      ),
                      ListTile(
                        title: Text("Video port"),
                        subtitle: Text(connectionMethod.videoPort.toString()),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outlined,
                color: theme.colorScheme.error,
              ),
              title: Text(
                "Delete car",
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.error),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text("Confirm delete car"),
                    content: Text(
                        "Are you sure you want to delete ${car.name}? You will have to import or add it again."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          final carBloc = dialogContext.read<CarBloc>();
                          carBloc.add(DeleteCar(car: car));
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Delete",
                          style: theme.textTheme.labelLarge!
                              .copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
