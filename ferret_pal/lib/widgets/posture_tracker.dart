import 'dart:async';
import 'dart:convert';
import 'package:ferret_pal/view_models/session_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/session_timer.dart';

// Message label for posture alerts
class PostureTracker extends StatefulWidget {
  final bool isRunning;
  final bool isPaused;
  const PostureTracker({super.key, required this.isRunning, required this.isPaused});

  @override
  State<PostureTracker> createState() => _PostureTrackerState();
}

class _PostureTrackerState extends State<PostureTracker> {
  bool isPostureGood = true;
  StreamSubscription<bool>? _postureSubscription;

  @override
  void initState() {
    super.initState();
    // Grab your VM once:
    final vm = Provider.of<SessionViewModel>(context, listen: false);
    // Subscribe immediately to the postureStream:
    _postureSubscription = vm.postureStream.listen((good) {
      print("Got posture event: $good");
      if (mounted && widget.isRunning && !widget.isPaused) {
        setState(() => isPostureGood = good);
      }
    }, onError: (e) {
      print("Posture stream error: $e");
    });
  }

  @override
  void dispose() {
    _postureSubscription?.cancel();
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