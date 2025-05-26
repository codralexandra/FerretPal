import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SessionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionDetailScreen({required this.session, super.key});

  @override
  Widget build(BuildContext context) {
    final postureEvents = List<Map<String, dynamic>>.from(session['posture_events']);
    final badSegments = List<Map<String, dynamic>>.from(session['bad_posture_segments']);
    final startTime = DateTime.parse(session['start_time']);
    final endTime = DateTime.parse(session['end_time']);
    final offsetValue = (session['offset'] as num).toDouble();

    final duration = endTime.difference(startTime);

    // Simplify data as before
    final downsampleFactor = 3;
    final simplifiedEvents = <Map<String, dynamic>>[];
    for (int i = 0; i < postureEvents.length; i += downsampleFactor) {
      simplifiedEvents.add(postureEvents[i]);
    }

    final spots = simplifiedEvents.map((event) {
      final time = DateTime.parse(event['timestamp']);
      final seconds = time.difference(startTime).inMilliseconds / 1000.0;
      return FlSpot(seconds.toDouble(), (event['value'] as num).toDouble());
    }).toList();

    final maxX = spots.isNotEmpty ? spots.last.x : 60.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200, // smaller height for the chart
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: (maxX / 4).clamp(5, 30),
                        getTitlesWidget: (value, _) =>
                            Text('${value.toInt()}s', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),  // <-- removes border lines
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 1.5,
                      color: Colors.black,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(enabled: false),
                  rangeAnnotations: RangeAnnotations(
                    verticalRangeAnnotations: badSegments.map((segment) {
                      final x1 = DateTime.parse(segment['start'])
                          .difference(startTime)
                          .inMilliseconds / 1000.0;
                      final x2 = DateTime.parse(segment['end'])
                          .difference(startTime)
                          .inMilliseconds / 1000.0;
                      return VerticalRangeAnnotation(
                        x1: x1,
                        x2: x2,
                        color: Colors.red.withOpacity(0.2),
                      );
                    }).toList(),
                    horizontalRangeAnnotations: [
                      HorizontalRangeAnnotation(
                        y1: offsetValue,
                        y2: offsetValue,
                        color: Colors.green.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Session Start: ${startTime.toLocal()}'),
            Text('Session End: ${endTime.toLocal()}'),
            Text('Duration: ${duration.inMinutes} minutes ${duration.inSeconds % 60} seconds'),
            Text('Number of breaks: ${badSegments.length}'),
          ],
        ),
      ),
    );
  }
}
