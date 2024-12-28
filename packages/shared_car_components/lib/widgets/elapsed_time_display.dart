import 'dart:async';

import 'package:app_utilities/app_utilities.dart';
import 'package:shared_car_components/widgets/video_overlay_text.dart';
import 'package:flutter/material.dart';

class ElapsedTimeDisplay extends StatefulWidget {
  final DateTime startTime;

  const ElapsedTimeDisplay({super.key, required this.startTime});

  @override
  State<ElapsedTimeDisplay> createState() => _ElapsedTimeDisplayState();
}

class _ElapsedTimeDisplayState extends State<ElapsedTimeDisplay> {
  late final Timer timer;
  var formattedElapsedTime = "00:00.00";

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      final elapsedTime = DateTime.now().difference(widget.startTime);
      setState(() {
        formattedElapsedTime = generateElapsedTimeString(elapsedTime);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VideoOverlayText(
          text: formattedElapsedTime,
          tabularFigures: true,
        ),
      ],
    );
  }
}
