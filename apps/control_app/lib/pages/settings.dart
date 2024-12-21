import 'package:control_app/pages/settings/car_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text("Settings"),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.directions_car_outlined),
                title: Text("Cars"),
                subtitle: Text("Edit, add and remove cars"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CarManagementPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.speed_outlined),
                title: Text("Performance"),
                subtitle: Text("Caching, update rate"),
              ),
              ListTile(
                leading: Icon(Icons.restore_outlined),
                title: Text("Reset"),
                subtitle: Text("Restore default settings and removes all cars"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
