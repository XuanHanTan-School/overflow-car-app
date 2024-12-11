import 'package:overflow_car_api/src/command_type.dart';

class Command {
  final CommandType type;
  final Map<String, dynamic> data;

  const Command({required this.type, required this.data});
}