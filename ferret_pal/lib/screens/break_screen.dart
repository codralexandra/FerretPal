import 'dart:async';
import 'package:ferret_pal/widgets/posture_tracker.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../screens/main_dash.dart';
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
  final confettiController = ConfettiController();

  void playConfettiAnimation() async{
    confettiController.play();

    await Future.delayed(Duration(seconds: 5));

    confettiController.stop();
  }

  @override
  void initState(){
    posturePlayer.stop();
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

    playConfettiAnimation();
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
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    double progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;
    String timeDisplay =
        '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2,'0')}';
    return Scaffold(
      backgroundColor: Color(0xFFede6e8),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Back to Dashboard"),
            ),
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                Colors.green,
                Colors.lightGreen,
                Colors.greenAccent,
                Color(0xFF2E7D32), // dark green
                Color(0xFF66BB6A), // medium green
              ],
            )
          ],
        ),
      ),
    );
  }
}