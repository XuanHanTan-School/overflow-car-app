import 'package:car_management_bloc/car_management_bloc.dart';
import 'package:car_management_bloc/car_management_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/views/loading_view.dart';

Future<void> addCar({required BuildContext context}) async {
  String? validateName(String? name) {
    if (name == null || name == "") return "Name must not be empty";

    final carBloc = context.read<CarManagementBloc>();
    if (carBloc.state.currentCars.any((car) => car.name == name)) {
      return "Name has already been used";
    }

    return null;
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      final nameController = TextEditingController();
      String? name;
      final formKey = GlobalKey<FormState>();
      String? loadMsg;

      return StatefulBuilder(
        builder: (context, setStateDiag) => AlertDialog(
          title: Text("Add car"),
          content: loadMsg != null
              ? SizedBox(
                  height: 200,
                  child: LoadingView(message: loadMsg!),
                )
              : Form(
                  key: formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text("Name"),
                      border: OutlineInputBorder(),
                    ),
                    controller: nameController,
                    validator: validateName,
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    onChanged: (value) {
                      setStateDiag(() {
                        name = value;
                      });
                    },
                  ),
                ),
          actions: loadMsg != null
              ? null
              : [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: formKey.currentState?.validate() == true
                        ? () async {
                            setStateDiag(() {
                              loadMsg = "Adding car...";
                            });

                            final carBloc = context.read<CarManagementBloc>();
                            carBloc.add(AddCar(name: name!));
                            await carBloc.stream.firstWhere((state) =>
                                state.currentCars
                                    .indexWhere((car) => car.name == name) !=
                                -1);

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                          }
                        : null,
                    child: Text("Done"),
                  ),
                ],
        ),
      );
    },
  );
}
