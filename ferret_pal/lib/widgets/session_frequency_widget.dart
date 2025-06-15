import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../view_models/session_vm.dart';

enum SessionViewMode { daily, weekly, monthly }

class SessionFrequencyChart extends StatefulWidget {
  final String username;

  const SessionFrequencyChart({super.key, required this.username});

  @override
  State<SessionFrequencyChart> createState() => _SessionFrequencyChartState();
}

class _SessionFrequencyChartState extends State<SessionFrequencyChart> {
  late Future<List<DateTime>> _sessionsFuture;
  SessionViewMode _selectedMode = SessionViewMode.daily;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _loadSessions();
  }

  Future<List<DateTime>> _loadSessions() {
    return Provider.of<SessionViewModel>(context, listen: false)
        .loadAllSessionTimestamps(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DateTime>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("No session data available");

        final groupedData = _groupSessions(snapshot.data!);

        return Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Session Frequency",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<SessionViewMode>(
                      value: _selectedMode,
                      onChanged: (mode) {
                        if (mode != null) {
                          setState(() {
                            _selectedMode = mode;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: SessionViewMode.daily,
                          child: Text("Daily"),
                        ),
                        DropdownMenuItem(
                          value: SessionViewMode.weekly,
                          child: Text("Weekly"),
                        ),
                        DropdownMenuItem(
                          value: SessionViewMode.monthly,
                          child: Text("Monthly"),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: _selectedMode == SessionViewMode.daily
                      ? _buildDailyLineChart(groupedData)
                      : _buildBarChart(groupedData),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyLineChart(List<int> data) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: (data.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                const labels = {
                  0: '00:00',
                  6: '06:00',
                  12: '12:00',
                  18: '18:00',
                  23: '23:00',
                };
                if (labels.containsKey(value.toInt())) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(labels[value.toInt()]!, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, _) {
                const labels = [5, 10, 15, 20, 30];
                if (labels.contains(value.toInt())) {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<int> data) {
    return BarChart(
      BarChartData(
        barGroups: data
            .asMap()
            .entries
            .map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              width: 16,
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            )
          ],
        ))
            .toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (_selectedMode == SessionViewMode.weekly) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value >= 0 && value < days.length) {
                    return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                  }
                } else if (_selectedMode == SessionViewMode.monthly) {
                  return Text('W${value.toInt() + 1}', style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }


  List<int> _groupSessions(List<DateTime> sessions) {
    final now = DateTime.now();
    final result = switch (_selectedMode) {
      SessionViewMode.daily => List.filled(24, 0),
      SessionViewMode.weekly => List.filled(7, 0),
      SessionViewMode.monthly => List.filled(5, 0),
    };

    for (var session in sessions) {
      switch (_selectedMode) {
        case SessionViewMode.daily:
          if (_isSameDay(session, now)) result[session.hour]++;
          break;
        case SessionViewMode.weekly:
          if (_isSameWeek(session, now)) result[session.weekday - 1]++;
          break;
        case SessionViewMode.monthly:
          if (session.month == now.month && session.year == now.year) {
            final weekIndex = ((session.day - 1) ~/ 7).clamp(0, 4);
            result[weekIndex]++;
          }
          break;
      }
    }

    return result;
  }

  bool _isSameWeek(DateTime d1, DateTime d2) {
    final start = d2.subtract(Duration(days: d2.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return d1.isAfter(start.subtract(const Duration(seconds: 1))) &&
        d1.isBefore(end.add(const Duration(seconds: 1)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getLabelForIndex(int index) {
    return switch (_selectedMode) {
      SessionViewMode.daily => '$index h',
      SessionViewMode.weekly => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
      SessionViewMode.monthly => 'W${index + 1}',
    };
  }
}
