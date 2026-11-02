import 'dart:async';
import 'package:ferret_pal/screens/break_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/session_vm.dart';
import '../view_models/profile_vm.dart';

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
  bool isOnBreak = false;
  bool endedManually = false;
  bool showPostureTracker = true;

  // Session details
  DateTime? startTime;
  bool isLoading = false;

  // Current user
  String username = "";

  Future<void> loadUser() async{
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    username = profileViewModel.username;
  }

  Future<void> startSession() async {
    setState(()=> isLoading = true);
    final sessionViewModel = Provider.of<SessionViewModel>(
        context, listen: false);
    try {
      loadUser();
      await sessionViewModel.startSession(username);
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
      await sessionViewModel.stopSession(username);
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

    endedManually = false;

    await startSession();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text('Calibrating...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please sit straight for about 6 seconds, FerretPal is calibrating the sensors...'),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        }
    );

    await Future.delayed(Duration(seconds: 6));
    if (mounted){
      Navigator.of(context).pop();
    }

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
    posturePlayer.stop();
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

  void manualStop(){
    endedManually = true;
    posturePlayer.stop();
    stopTimer();
  }

  void stopTimer() async{
    timer?.cancel();
    posturePlayer.stop();

    await stopSession();

    setState((){
      totalSeconds = 0;
      remainingSeconds = 0;
      isRunning = false;
      isPaused = false;
      showPostureTracker = false;
    });

    if(!endedManually){
      if(mounted){
        posturePlayer.stop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BreakScreen(
              onBreakEnd: (){
                Navigator.pop(context);
                setState((){
                  showPostureTracker = true;
                });
              },
            ),
          ),
        );
      }
    }

  }

  @override
  void dispose(){
    super.dispose();
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
      backgroundColor: Color(0xFFede6e8),
      appBar: AppBar(title: Text("Start a work session!")),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(showPostureTracker)
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
                  onStop: manualStop,
                  onResume: resumeTimer,
                  onHourChange: (value) => setState(() => selectedHours = value),
                  onMinuteChange: (value) => setState(() => selectedMinutes = value),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}