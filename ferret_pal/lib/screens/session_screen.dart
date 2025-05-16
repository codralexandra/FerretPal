import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/session_vm.dart';

import '../widgets/posture_tracker.dart';
import '../widgets/session_timer.dart';
import '../widgets/timer_controls.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override _SessionScreenState createState() =>  _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>{
  // Session parameters
  // Timer parameters
  int selectedHours = 0;
  int selectedMinutes = 1;
  int totalSeconds = 0;
  int remainingSeconds = 0;
  Timer? timer;
  bool isRunning = false;
  bool isPaused = false;

  // Session details
  DateTime? startTime;
  bool isLoading = false;

  // Asyncs to implement
  Future<void> startSession() async {
    setState(()=> isLoading = true);
    final sessionViewModel = Provider.of<SessionViewModel>(
        context, listen: false);
    try {
      await sessionViewModel.startSession();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally{
      setState(() => isLoading = false);
    }
  }

  Future<void> stopSession() async {
    final sessionViewModel = Provider.of<SessionViewModel>(
        context, listen: false);
    try {
      await sessionViewModel.stopSession();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> saveValues() async {
    final sessionViewModel = Provider.of<SessionViewModel>(
        context, listen: false);
    try {
      await sessionViewModel.saveValues();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> saveSession() async {
    final sessionViewModel = Provider.of<SessionViewModel>(
        context, listen: false);
    try {
      await sessionViewModel.saveSession();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Timer methods
  void startTimer() async{
    totalSeconds = (selectedHours * 3600) + (selectedMinutes * 60);
    remainingSeconds = totalSeconds;
    startTime = DateTime.now();

    await startSession();

    setState((){
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(Duration(seconds: 1), (Timer t){
      if(remainingSeconds > 0){
        setState(() {
          remainingSeconds--;
        });
      }else {
        stopTimer();
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState((){
      isPaused = true;
    });
  }

  void resumeTimer(){
    setState((){
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(Duration(seconds: 1), (Timer t){
      if(remainingSeconds > 0 ) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() async{
    timer?.cancel();

    await stopSession();

    setState((){
      totalSeconds = 0;
      remainingSeconds = 0;
      isRunning = false;
      isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;
    String timeDisplay =
        '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';

    // Shows a loading progress after starting a session
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Starting Session...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Start a work session!")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PostureTracker(isRunning: isRunning, isPaused: isPaused),
            SizedBox(height: 40),
            SessionTimer(progress: progress, timeDisplay: timeDisplay),
            SizedBox(height: 20),
            TimerControls(
              isRunning: isRunning,
              isPaused: isPaused,
              selectedHours: selectedHours,
              selectedMinutes: selectedMinutes,
              onStart: startTimer,
              onPause: pauseTimer,
              onStop: stopTimer,
              onResume: resumeTimer,
              onHourChange: (value) => setState(() => selectedHours = value),
              onMinuteChange: (value) => setState(() => selectedMinutes = value),
            ),
          ],
        ),
      ),
    );
  }
}