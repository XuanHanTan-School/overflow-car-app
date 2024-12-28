import 'dart:convert';

import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart' as car_event;
import 'package:car_management_bloc/car_management_bloc.dart';
import 'package:car_management_bloc/car_management_event.dart'
    as car_management_event;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_api/overflow_car.dart';

Future<void> importCarsFromJson(
    {bool isManagementMode = false, required BuildContext context}) async {
  var result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  // The result will be null, if the user aborted the dialog
  if (result != null) {
    final file = result.files.single.xFile;

    try {
      final bytes = await file.readAsBytes();
      final jsonString = utf8.decode(bytes);
      final decodedJson = jsonDecode(jsonString);

      if (!context.mounted) return;
      if (isManagementMode) {
        final carManagementBloc = context.read<CarManagementBloc>();

        for (final carJson in decodedJson) {
          final car = Car.fromJson(jsonEncode(carJson));
          carManagementBloc.add(car_management_event.AddCar(name: car.name));
        }
      } else {
        final carBloc = context.read<CarBloc>();

        for (final carJson in decodedJson) {
          final car = Car.fromJson(jsonEncode(carJson));
          carBloc.add(car_event.AddCar(
            name: car.name,
            host: car.host,
            commandPort: car.commandPort,
            videoPort: car.videoPort,
          ));
        }
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

String toOrdinal(int number) {
  if (number < 0) throw Exception('Invalid Number');

  switch (number % 10) {
    case 1:
      return '${number}st';
    case 2:
      return '${number}nd';
    case 3:
      return '${number}rd';
    default:
      return '${number}th';
  }
}

String generateElapsedTimeString(Duration elapsedTime) {
  final minutes = elapsedTime.inMinutes.toString();
  final seconds = (elapsedTime.inSeconds % 60).toString().padLeft(2, "0");
  final milliseconds =
      (elapsedTime.inMilliseconds % 1000).toString().padLeft(3, "0");

  return "$minutes:$seconds.$milliseconds";
}
