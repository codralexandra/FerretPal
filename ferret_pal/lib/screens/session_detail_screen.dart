import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../view_models/session_vm.dart';
import '../view_models/profile_vm.dart';

class SessionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> session;

  const SessionDetailScreen({required this.session, super.key});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Map<String, dynamic>? comparison;
  Map<String, dynamic>? otherSession;
  bool isLoadingComparison = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadComparison();
    _loadOtherSession();
  }

  Future<void> _loadOtherSession() async{
    final sessionViewModel = Provider.of<SessionViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    try {
      final session = await sessionViewModel.loadSecondToLastSession(profileViewModel.username);
      setState(() {
        otherSession = session;
      });
    } catch (e) {
      debugPrint("Failed to load second session: $e");
    }
  }

  Future<void> _loadComparison() async {
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    try {
      final comp = await sessionVM.compareSessions(profileVM.username);
      setState(() {
        comparison = comp;
        isLoadingComparison = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load comparison.";
        isLoadingComparison = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postureEvents = List<Map<String, dynamic>>.from(widget.session['posture_events']);
    final badSegments = List<Map<String, dynamic>>.from(widget.session['bad_posture_segments']);
    final startTime = DateTime.parse(widget.session['start_time']);
    final endTime = DateTime.parse(widget.session['end_time']);
    final offsetValue = (widget.session['offset'] as num).toDouble();

    final duration = endTime.difference(startTime);

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
      backgroundColor: const Color(0xFFede6e8),
      appBar: AppBar(
        title: const Text('Session Details'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Posture Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: maxX,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _buildSpots(widget.session),
                              isCurved: true,
                              barWidth: 2,
                              color: Colors.black,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                            ),
                            if (otherSession != null)
                              LineChartBarData(
                                spots: _buildSpots(otherSession!),
                                isCurved: true,
                                barWidth: 2,
                                color: Colors.blue,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: false),
                              ),
                          ],
                          rangeAnnotations: RangeAnnotations(
                            verticalRangeAnnotations: [
                              ..._buildBadSegments(widget.session, Colors.red.withOpacity(0.2)),
                              if (otherSession != null)
                                ..._buildBadSegments(otherSession!, Colors.blue.withOpacity(0.2)),
                            ],
                            horizontalRangeAnnotations: [
                              HorizontalRangeAnnotation(
                                y1: offsetValue,
                                y2: offsetValue,
                                color: Colors.green.withOpacity(0.8),
                              ),
                            ],
                          ),
                          lineTouchData: LineTouchData(enabled: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.line_axis, color: Colors.black, size: 14),
                        SizedBox(width: 4),
                        Text("Current Session", style: TextStyle(fontSize: 12)),
                        SizedBox(width: 16),
                        Icon(Icons.line_axis, color: Colors.blue, size: 14),
                        SizedBox(width: 4),
                        Text("Previous Session", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Comparison Section
            if (isLoadingComparison)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red))
            else if (comparison != null)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildComparisonWidget(),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonWidget() {
    final summary = comparison!['summary'] ?? 'No summary available';
    final prev = comparison!['previous_session'] ?? {};
    final curr = comparison!['current_session'] ?? {};
    final changes = comparison!['changes'] ?? {};
    final weighted = comparison!['weighted_score_components'] ?? {};
    final totalScore = comparison!['total_score'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.lightGreen,
          ),
        ),
        const SizedBox(height: 12),

        // Main comparison table
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.lightGreen.shade100),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Metric', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Previous', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Current', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            _buildTableRow('Total Breaks', prev['breaks']?.toString() ?? 'N/A', curr['breaks']?.toString() ?? 'N/A'),
            _buildTableRow('Good Posture Time (s)', prev['good_posture_seconds']?.toString() ?? 'N/A', curr['good_posture_seconds']?.toString() ?? 'N/A'),
            _buildTableRow('Duration (s)', prev['duration_seconds']?.toString() ?? 'N/A', curr['duration_seconds']?.toString() ?? 'N/A'),
          ],
        ),
        // const SizedBox(height: 20),
        //
        // Text('Changes:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.lightGreen)),
        // const SizedBox(height: 6),
        // Text('Breaks Change (%): ${changes['breaks_change_percent']?.toStringAsFixed(2) ?? 'N/A'}'),
        // Text('Posture Change (%): ${changes['posture_change_percent']?.toStringAsFixed(2) ?? 'N/A'}'),
        // Text('Duration Change (%): ${changes['duration_change_percent']?.toStringAsFixed(2) ?? 'N/A'}'),
        //
        // const SizedBox(height: 12),
        //
        // Text('Weighted Score Components:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.lightGreen)),
        // const SizedBox(height: 6),
        // Text('Breaks Contribution: ${weighted['breaks_contribution']?.toStringAsFixed(2) ?? 'N/A'}'),
        // Text('Posture Contribution: ${weighted['posture_contribution']?.toStringAsFixed(2) ?? 'N/A'}'),
        // Text('Duration Contribution: ${weighted['duration_contribution']?.toStringAsFixed(2) ?? 'N/A'}'),

        const SizedBox(height: 12),
        Text(
          'Total Score: ${totalScore.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }


  TableRow _buildTableRow(String metric, String prev, String curr) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(metric),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(prev, textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(curr, textAlign: TextAlign.center),
      ),
    ]);
  }

  List<FlSpot> _buildSpots(Map<String, dynamic> session) {
    final events = List<Map<String, dynamic>>.from(session['posture_events']);
    final startTime = DateTime.parse(session['start_time']);
    const downsampleFactor = 3;

    final simplified = <Map<String, dynamic>>[];
    for (int i = 0; i < events.length; i += downsampleFactor) {
      simplified.add(events[i]);
    }

    return simplified.map((event) {
      final t = DateTime.parse(event['timestamp']);
      final seconds = t.difference(startTime).inMilliseconds / 1000.0;
      return FlSpot(seconds.toDouble(), (event['value'] as num).toDouble());
    }).toList();
  }

  List<VerticalRangeAnnotation> _buildBadSegments(Map<String, dynamic> session, Color color) {
    final badSegments = List<Map<String, dynamic>>.from(session['bad_posture_segments']);
    final startTime = DateTime.parse(session['start_time']);

    return badSegments.map((segment) {
      final x1 = DateTime.parse(segment['start']).difference(startTime).inMilliseconds / 1000.0;
      final x2 = DateTime.parse(segment['end']).difference(startTime).inMilliseconds / 1000.0;
      return VerticalRangeAnnotation(
        x1: x1,
        x2: x2,
        color: color,
      );
    }).toList();
  }

}
