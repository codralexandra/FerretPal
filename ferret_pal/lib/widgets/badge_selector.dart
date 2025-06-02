import 'package:flutter/material.dart';

class BadgeSelector extends StatefulWidget {
  final List<String> enabledBadges;
  final Function(List<String>) onSelectionChanged;

  const BadgeSelector({
    Key? key,
    required this.enabledBadges,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _BadgeSelectorState createState() => _BadgeSelectorState();
}

class _BadgeSelectorState extends State<BadgeSelector> {
  late List<String> selectedBadges;

  @override
  void initState() {
    super.initState();
    selectedBadges = List.from(widget.enabledBadges);
  }

  void _toggleBadge(String badgeKey) {
    setState(() {
      if (selectedBadges.contains(badgeKey)) {
        selectedBadges.remove(badgeKey);
      } else {
        selectedBadges.add(badgeKey);
      }
      widget.onSelectionChanged(selectedBadges);
    });
  }

  @override
  Widget build(BuildContext context) {
    final badgeOptions = {
      'least_breaks': 'Least Breaks',
      'total_sessions_completed': 'Sessions Completed',
      'total_focus_time': 'Focus Time',
      'good_posture_streak': 'Good Posture Streak',
      'consecutive_days_used': 'Day Streak',
      // Add more if needed
    };

    return ListView(
      shrinkWrap: true,
      children: badgeOptions.entries.map((entry) {
        final key = entry.key;
        final label = entry.value;
        final selected = selectedBadges.contains(key);
        return CheckboxListTile(
          title: Text(label),
          value: selected,
          onChanged: (_) => _toggleBadge(key),
        );
      }).toList(),
    );
  }
}