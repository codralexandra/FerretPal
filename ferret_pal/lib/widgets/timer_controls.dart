import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

// Timer buttons for time selection, pause, stop &start
class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final int selectedHours;
  final int selectedMinutes;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final ValueChanged<int> onHourChange;
  final ValueChanged<int> onMinuteChange;

  const TimerControls({super.key,
    required this.isRunning,
    required this.isPaused,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    required this.onResume,
    required this.onHourChange,
    required this.onMinuteChange,
  });

  @override
  Widget build(BuildContext context) {
    if (isRunning) {
      return isPaused
          ? ElevatedButton(
        onPressed: onResume,
        child: Text("Resume"),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPause,
            child: Text("Pause"),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: onStop,
            child: Text("Stop"),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children:[
                Text("Hours", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                NumberPicker(
                  value: selectedHours,
                  minValue: 0,
                  maxValue: 8,
                  onChanged: (value) => onHourChange(value),
                ),
              ],
            ),
            SizedBox(width: 20),
            Column(
              children:[
                Text("Minutes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                NumberPicker(
                  value: selectedMinutes,
                  minValue: 1,
                  maxValue: 59,
                  onChanged: (value) => onMinuteChange(value),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onStart,
          child: Text("Start"),
        ),
      ],
    );
  }
}
