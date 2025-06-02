import 'package:ferret_pal/widgets/badge_selector.dart';
import 'package:ferret_pal/widgets/badge_widget.dart';
import 'package:ferret_pal/widgets/last_session_overview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/profile_vm.dart';

import '../screens/session_screen.dart';

/// Main dashboard of the application
class Dashboard extends StatefulWidget{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>{
  final GlobalKey<LastSessionOverviewState> _lastSessionKey = GlobalKey();

  @override
  void initState(){
    super.initState();
    // Get the user information for data display
    _loadUserInfoAndBadges();
  }

  // Asynchronously load the user information using the ProfileViewModel class
  Future<void> _loadUserInfoAndBadges() async {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    await profileViewModel.getFullInfo();
    await profileViewModel.getBadgePreferences();
  }

  void _refreshWidgets() {
    _lastSessionKey.currentState?.refreshData();
    setState(() {});
  }

  void _openBadgeSelector() {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: BadgeSelector(
            enabledBadges: List.from(profileViewModel.selectedBadges),
            onSelectionChanged: (selected) async {
              await profileViewModel.saveBadgePreferences(selected);
              setState(() {}); // Refresh UI after save
            },
          ),
        );
      },
    );
  }

  String _getBadgeValue(String badgeKey, ProfileViewModel vm) {
    switch (badgeKey) {
      case 'least_breaks':
        return vm.leastBreaks?.toString() ?? '-';
      case 'total_sessions_completed':
        return vm.totalSessionsCompleted.toString();
      case 'total_focus_time':
      // Convert seconds or minutes nicely here if needed, for now just raw int
        return vm.totalFocusTime.toString();
      case 'good_posture_streak':
        return vm.goodPostureStreak.toString();
      case 'consecutive_days_used':
        return vm.consecutiveDaysUsed.toString();
      default:
        return '-';
    }
  }

  IconData _getBadgeIcon(String badgeKey) {
    switch (badgeKey) {
      case 'least_breaks':
        return Icons.timer_off;
      case 'total_sessions_completed':
        return Icons.check_circle_outline;
      case 'total_focus_time':
        return Icons.timer;
      case 'good_posture_streak':
        return Icons.accessibility_new;
      case 'consecutive_days_used':
        return Icons.calendar_today;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ${profileViewModel.displayName}!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.badge),
            tooltip: 'Select Badges',
            onPressed: _openBadgeSelector,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserInfoAndBadges();
          _refreshWidgets();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          children: [
            Text('Your Badges', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: profileViewModel.selectedBadges.length,
                separatorBuilder: (context, index) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final badgeKey = profileViewModel.selectedBadges[index];
                  return BadgeWidget(
                    title: badgeKey.replaceAll('_', ' ').toUpperCase(),
                    value: _getBadgeValue(badgeKey, profileViewModel),
                    icon: _getBadgeIcon(badgeKey),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            LastSessionOverview(key: _lastSessionKey),
            // more widgets here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SessionScreen()),
          );
        },
        icon: const Icon(Icons.access_time),
        label: const Text('Start Session'),
      ),
    );
  }
}