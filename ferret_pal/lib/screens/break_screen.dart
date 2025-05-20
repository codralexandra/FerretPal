import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/session_timer.dart';

class BreakScreen extends StatefulWidget{
  final VoidCallback onBreakEnd;
  const BreakScreen({super.key, required this.onBreakEnd});

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen>{
  late int totalSeconds = 1*60;
  late int remainingSeconds;
  Timer? breakTimer;

  @override
  void initState(){
    super.initState();
    remainingSeconds = totalSeconds;

    breakTimer = Timer.periodic(Duration(seconds:1), (timer) {
      if(remainingSeconds > 0){
        setState(() {
          remainingSeconds--;
        });
      } else {
        _handleBreakComplete();
      }
    });
  }

  void _handleBreakComplete(){
    breakTimer?.cancel();
    Future.delayed(Duration(seconds:2),(){
      widget.onBreakEnd();
    });
  }

  @override
  void dispose(){
    breakTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    double progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;
    String timeDisplay =
        '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2,'0')}';
    return Scaffold(
      appBar: AppBar(title: Text("Break Time!")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Take your time and stretch!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            SessionTimer(progress: progress, timeDisplay: timeDisplay),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).popUntil((route)=>route.isFirst);
              },
              child: Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}