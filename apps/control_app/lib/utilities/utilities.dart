import 'dart:convert';

import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overflow_car_api/overflow_car.dart';

Future<void> importCarsFromJson({required BuildContext context}) async {
  var result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['json'], );

  // The result will be null, if the user aborted the dialog
  if (result != null) {
    final file = result.files.single.xFile;
    
    try {
      final bytes = await file.readAsBytes();
      final jsonString = utf8.decode(bytes);
      final decodedJson = jsonDecode(jsonString);

      if (!context.mounted) return;
      final carBloc = context.read<CarBloc>();

      for (final carJson in decodedJson) {
        final car = Car.fromJson(jsonEncode(carJson));
        carBloc.add(AddCar(
            name: car.name,
            host: car.host,
            commandPort: car.commandPort,
            videoPort: car.videoPort));
      }
    } catch (e) {
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text("Failed to import cars"),
          content: Text("The JSON file provided is of an invalid format."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      );
    }
  }
}
