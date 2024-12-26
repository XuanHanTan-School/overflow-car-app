import 'dart:async';

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
      final minutes = elapsedTime.inMinutes.toString();
      final seconds = (elapsedTime.inSeconds % 60).toString().padLeft(2, "0");
      final milliseconds = (elapsedTime.inMilliseconds % 1000).toString().padLeft(3, "0");

      setState(() {
        formattedElapsedTime = "$minutes:$seconds.$milliseconds";
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
        VideoOverlayText(text: formattedElapsedTime),
      ],
    );
  }
}
