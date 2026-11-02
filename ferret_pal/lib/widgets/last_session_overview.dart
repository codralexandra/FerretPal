import 'package:ferret_pal/screens/session_detail_screen.dart';
import 'package:ferret_pal/view_models/session_vm.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../view_models/session_vm.dart';
import '../view_models/profile_vm.dart';

class LastSessionOverview extends StatefulWidget {
  final String username;

  const LastSessionOverview({super.key, required this.username});

  @override
  State<LastSessionOverview> createState() => LastSessionOverviewState();
}

class LastSessionOverviewState extends State<LastSessionOverview> {
  final SessionViewModel _sessionViewModel = SessionViewModel();
  late Future<Map<String,dynamic>> _sessionFuture;

  @override
  void initState(){
    super.initState();
    _loadSession();
  }

  void _loadSession(){
    _sessionFuture = _sessionViewModel.loadLastSession(widget.username);
  }


  void refreshData() {
    setState(() {
      _loadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading last session'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No previous session found'));
        }

        final session = snapshot.data!;
        final postureEvents = List<Map<String, dynamic>>.from(session['posture_events']);
        final badSegments = List<Map<String, dynamic>>.from(session['bad_posture_segments']);
        final startTime = DateTime.parse(session['start_time']);
        final offsetValue = (session['offset'] as num).toDouble();

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

        return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionDetailScreen(session: session),
                ),
              );
            },
            child:  Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Session Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 1.8,
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
                const SizedBox(height: 8),
                _buildLegend(),
              ],
            ),
          ),
        )
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(color: Colors.black, label: 'Sensor value'),
        const SizedBox(width: 16),
        _legendDot(color: Colors.red.withOpacity(0.3), label: 'Bad posture'),
      ],
    );
  }

  Widget _legendDot({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}