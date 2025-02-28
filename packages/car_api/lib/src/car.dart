import 'dart:async';
import 'dart:convert';

import 'package:car_api/src/command.dart';
import 'package:web_socket/web_socket.dart';

class Car {
  final String name;
  final String host;
  final int commandPort;
  final int videoPort;
  final String username;
  final String password;
  final StreamController<bool> connectionState = StreamController.broadcast();

  bool _isConnected = false;
  WebSocket? socket;

  Car({
    required this.name,
    required this.host,
    required this.commandPort,
    required this.videoPort,
    required this.username,
    required this.password,
  });

  factory Car.fromJson(String json) {
    var data = JsonDecoder().convert(json);
    return Car(
      name: data["name"],
      host: data["host"],
      commandPort: data["commandPort"],
      videoPort: data["videoPort"],
      username: data["username"],
      password: data["password"],
    );
  }

  void checkIsConnected() {
    if (!_isConnected) {
      throw StateError(
          "Car has not been connected yet. Call the connect() method.");
    }
  }

  Future<void> connect() async {
    socket = await WebSocket.connect(
        Uri(scheme: "ws", host: host, port: commandPort));
    _isConnected = true;
    connectionState.add(_isConnected);

    socket!.events.listen((e) async {
      switch (e) {
        case CloseReceived(code: final code, reason: final reason):
          print('Connection to server closed: $code [$reason]');
          _isConnected = false;
          connectionState.add(_isConnected);
          break;
        default:
          break;
      }
    });
  }

  void sendCommand(Command command) {
    checkIsConnected();

    socket!.sendText(JsonEncoder().convert({
      "type": command.type.typeStr,
      ...command.data,
      "token": password,
    }));
  }

  Future<void> disconnect() async {
    await socket?.close();
    _isConnected = false;
    connectionState.add(_isConnected);
  }

  String toJson() {
    return JsonEncoder().convert({
      "name": name,
      "host": host,
      "commandPort": commandPort,
      "videoPort": videoPort,
      "username": username,
      "password": password
    });
  }
}
