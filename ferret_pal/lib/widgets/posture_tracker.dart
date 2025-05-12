import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Message label for posture alerts
class PostureTracker extends StatefulWidget {
  final bool isRunning;
  final bool isPaused;
  const PostureTracker({super.key, required this.isRunning, required this.isPaused});

  @override
  State<PostureTracker> createState() => _PostureTrackerState();
}

class _PostureTrackerState extends State<PostureTracker> {
  bool isPostureGood = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRunning || widget.isPaused) {
      return Text('');
    }
    return Text(
      isPostureGood ? 'Your posture is great!' : 'Fix your posture!',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        background: Paint()
          ..strokeWidth = 30.0
          ..color = isPostureGood
              ? const Color.fromARGB(255, 117, 170, 117)
              : const Color.fromARGB(255, 220, 131, 131)
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      ),
    );
  }
}