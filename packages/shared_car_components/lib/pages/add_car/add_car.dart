import 'package:car_api/overflow_car.dart';
import 'package:car_bloc/car_bloc.dart';
import 'package:car_bloc/car_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_car_components/pages/add_car/select_connection_method.dart';

class AddCarPage extends StatefulWidget {
  final ConnectionMethodType connectionMethodType;

  const AddCarPage({super.key, required this.connectionMethodType});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final nameController = TextEditingController();
  final hostController = TextEditingController();
  final commandPortController = TextEditingController();
  final videoPortController = TextEditingController();
  final proxyUrlController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? host;
  int? commandPort;
  int? videoPort;
  String? proxyUrl;
  String? username;
  String? password;

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
    if (name == null || name == "") return "Name must not be empty";

    final carBloc = context.read<CarBloc>();
    if (carBloc.state.currentCars.any((car) => car.name == name)) {
      return "Name has already been used";
    }

    return null;
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

  String? validateUsername(String? username) {
    if (username == null || username == "") return "Username must not be empty";
    return RegExp(r"^[a-zA-Z0-9]+$").hasMatch(username)
        ? null
        : "Invalid username";
  }

  String? validatePassword(String? password) {
    if (password == null || password == "") return "Password must not be empty";
    return RegExp(r"^[a-zA-Z0-9]+$").hasMatch(password)
        ? null
        : "Invalid password";
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLargeScreen = mediaQuery.size.shortestSide > 600;

    return BlocProvider.value(
      value: BlocProvider.of<CarBloc>(context),
      child: Scaffold(
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
              padding: EdgeInsets.symmetric(horizontal: 16)
                  .copyWith(bottom: 16 + (isLargeScreen ? 16 : 0)),
              child: Column(
                spacing: 10,
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 400),
                        child: ListView(
                          children: [
                            SizedBox(
                              height: 16 + (isLargeScreen ? 16 : 0),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text("Name"),
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 40,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              controller: nameController,
                              validator: validateName,
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              onChanged: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                            ),
                            if (widget.connectionMethodType ==
                                ConnectionMethodType.direct) ...[
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
                            ] else if (widget.connectionMethodType ==
                                ConnectionMethodType.reverseProxy) ...[
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text("Proxy URL"),
                                  border: OutlineInputBorder(),
                                ),
                                controller: proxyUrlController,
                                validator: validateHost,
                                autovalidateMode: AutovalidateMode.onUnfocus,
                                onChanged: (value) {
                                  setState(() {
                                    proxyUrl = value;
                                  });
                                },
                              ),
                            ],
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text("Username"),
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 40,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              controller: usernameController,
                              validator: validateUsername,
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text("Password"),
                                border: OutlineInputBorder(),
                              ),
                              controller: passwordController,
                              obscureText: true,
                              validator: validatePassword,
                              autovalidateMode: AutovalidateMode.onUnfocus,
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _formKey.currentState?.validate() ?? false
                        ? () {
                            final CarConnectionMethod connectionMethod;

                            switch (widget.connectionMethodType) {
                              case ConnectionMethodType.direct:
                                connectionMethod = CarConnectionMethodDirect(
                                  host: host!,
                                  commandPort: commandPort!,
                                  videoPort: videoPort!,
                                  username: username!,
                                  password: password!,
                                );
                                break;
                              case ConnectionMethodType.reverseProxy:
                                connectionMethod =
                                    CarConnectionMethodReverseProxy(
                                  proxyUrl: proxyUrl!,
                                  username: username!,
                                  password: password!,
                                );
                                break;
                            }

                            context.read<CarBloc>().add(
                                  AddCar(
                                    name: name!,
                                    connectionMethod: connectionMethod,
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
    );
  }
}
