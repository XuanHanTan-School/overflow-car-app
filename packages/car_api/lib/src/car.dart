import 'dart:async';
import 'dart:convert';

import 'package:car_api/src/command.dart';
import 'package:web_socket/web_socket.dart';

class Car {
  final String name;
  final CarConnectionMethod connectionMethod;
  final StreamController<bool> connectionState = StreamController.broadcast();

  bool _isConnected = false;
  WebSocket? socket;

  Car({
    required this.name,
    required this.connectionMethod,
  });

  factory Car.fromJson(String json) {
    var data = JsonDecoder().convert(json);
    return Car(
      name: data["name"],
      connectionMethod: CarConnectionMethod.fromMap(data["connectionMethod"]),
    );
  }

  void checkIsConnected() {
    if (!_isConnected) {
      throw StateError(
          "Car has not been connected yet. Call the connect() method.");
    }
  }

  Future<void> connect() async {
    socket = await WebSocket.connect(Uri.parse(connectionMethod.commandUrl));
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
      "token": connectionMethod.password,
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
      "connectionMethod": connectionMethod.toMap(),
    });
  }
}

abstract class CarConnectionMethod {
  final String username;
  final String password;

  CarConnectionMethod({required this.username, required this.password});

  String get commandUrl;
  String get videoUrl;

  static CarConnectionMethod fromMap(Map<String, dynamic> data) {
    if (data["host"] != null) {
      return CarConnectionMethodDirect(
        host: data["host"],
        commandPort: data["commandPort"],
        videoPort: data["videoPort"],
        username: data["username"],
        password: data["password"],
      );
    } else {
      return CarConnectionMethodReverseProxy(
        proxyUrl: data["proxyUrl"],
        username: data["username"],
        password: data["password"],
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
    };
  }
}

class CarConnectionMethodDirect extends CarConnectionMethod {
  final String host;
  final int commandPort;
  final int videoPort;

  CarConnectionMethodDirect({
    required this.host,
    required this.commandPort,
    required this.videoPort,
    required super.username,
    required super.password,
  });

  @override
  String get commandUrl => "ws://$host:$commandPort";

  @override
  String get videoUrl =>
      "rtsp://${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}@$host:$videoPort/video_stream";

  @override
  Map<String, dynamic> toMap() {
    return {
      "host": host,
      "commandPort": commandPort,
      "videoPort": videoPort,
      ...super.toMap(),
    };
  }
}

class CarConnectionMethodReverseProxy extends CarConnectionMethod {
  final String proxyUrl;

  CarConnectionMethodReverseProxy({
    required this.proxyUrl,
    required super.username,
    required super.password,
  });

  @override
  String get commandUrl => "ws://$proxyUrl/command";

  @override
  String get videoUrl =>
      "rtsp://${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}@$proxyUrl/video";

  @override
  Map<String, dynamic> toMap() {
    return {
      "proxyUrl": proxyUrl,
      ...super.toMap(),
    };
  }
}
