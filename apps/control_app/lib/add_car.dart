import 'package:control_app/bloc/car_bloc.dart';
import 'package:control_app/bloc/car_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final nameController = TextEditingController();
  final hostController = TextEditingController();
  final commandPortController = TextEditingController();
  final videoPortController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? host;
  int? commandPort;
  int? videoPort;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  String? validateName(String? name) {
    return name != null ? null : "Name must not be empty";
  }

  String? validateHost(String? host) {
    const ipAddressRegex =
        r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
    const domainRegex =
        r"^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
    return host != null &&
            (RegExp(ipAddressRegex).hasMatch(host) ||
                RegExp(domainRegex).hasMatch(host))
        ? null
        : "Host must be a valid IP address/domain";
  }

  String? validatePort(String? portStr) {
    if (portStr != null) {
      final port = int.tryParse(portStr);
      if (port != null && port >= 0 && port <= 65535) {
        return null;
      }
    }

    return "Enter a valid port number (0 to 65535)";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("Add car"),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text("Name"),
                              border: OutlineInputBorder(),
                            ),
                            controller: nameController,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text("Host"),
                              border: OutlineInputBorder(),
                            ),
                            controller: hostController,
                            validator: validateHost,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            onChanged: (value) {
                              setState(() {
                                host = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text("Command port"),
                              border: OutlineInputBorder(),
                            ),
                            controller: commandPortController,
                            keyboardType: TextInputType.number,
                            validator: validatePort,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            onChanged: (value) {
                              setState(() {
                                commandPort = int.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text("Video port"),
                              border: OutlineInputBorder(),
                            ),
                            controller: videoPortController,
                            keyboardType: TextInputType.number,
                            validator: validatePort,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            onChanged: (value) {
                              setState(() {
                                videoPort = int.tryParse(value);
                              });
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: _formKey.currentState?.validate() ?? false
                          ? () {
                              context.read<CarBloc>().add(
                                    AddCar(
                                      name: name!,
                                      host: host!,
                                      commandPort: commandPort!,
                                      videoPort: videoPort!,
                                    ),
                                  );
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text("Finish"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}