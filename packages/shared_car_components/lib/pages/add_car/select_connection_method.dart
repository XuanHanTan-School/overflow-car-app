import 'package:flutter/material.dart';
import 'package:shared_car_components/pages/add_car/add_car.dart';

enum ConnectionMethodType {
  direct,
  reverseProxy,
}

class SelectConnectionMethodPage extends StatefulWidget {
  const SelectConnectionMethodPage({super.key});

  @override
  State<SelectConnectionMethodPage> createState() =>
      _SelectConnectionMethodPageState();
}

class _SelectConnectionMethodPageState
    extends State<SelectConnectionMethodPage> {
  var connectionMethodType = ConnectionMethodType.reverseProxy;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLargeScreen = mediaQuery.size.shortestSide > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add car"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 16 + (isLargeScreen ? 16 : 0)),
        child: Column(
          children: [
            RadioListTile(
              value: ConnectionMethodType.direct,
              groupValue: connectionMethodType,
              onChanged: (value) => setState(() {
                connectionMethodType = value!;
              }),
              title: Text("Direct"),
              subtitle: Text("Connect directly to open ports on the car."),
            ),
            RadioListTile(
              value: ConnectionMethodType.reverseProxy,
              groupValue: connectionMethodType,
              onChanged: (value) => setState(() {
                connectionMethodType = value!;
              }),
              title: Text("Reverse proxy"),
              subtitle: Text(
                  "Connect to the car through a reverse proxy like Cloudflare Tunnels."),
            ),
            Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddCarPage(connectionMethodType: connectionMethodType),
                  ),
                );
              },
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
