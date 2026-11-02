import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/profile_vm.dart';
import '../screens/main_dash.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final success = await profileVM.getFullInfo();
    setState(() {
      _hasError = !success;
      _isLoading = false;
    });
  }

  String formatMinutesToHours(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '$hours hr${hours > 1 ? 's' : ''} ${mins > 0 ? '$mins min' : ''}'.trim();
    } else {
      return '$mins min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return const Center(child: Text('Error loading profile'));
    }

    return Scaffold(
      backgroundColor: Color(0xFFede6e8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
        title: const Text(
          'Your Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFede6e8), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAvatar(profileVM),
                const SizedBox(height: 12),
                Text(
                  profileVM.displayName ?? profileVM.username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (profileVM.firstSessionDate != null)
                  Text("Joined on ${profileVM.firstSessionDate}"),

                const SizedBox(height: 24),
                _buildStats(profileVM),
                const SizedBox(height: 24),
                _buildBadges(profileVM.selectedBadges),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ProfileViewModel vm) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(radius: 55, backgroundColor: Colors.lightGreen),
        CircleAvatar(
          radius: 50,
          backgroundImage: vm.profilePicturePath != null
              ? (vm.profilePicturePath!.startsWith('assets/')
              ? AssetImage(vm.profilePicturePath!)
              : FileImage(File(vm.profilePicturePath!))) as ImageProvider
              : const AssetImage('assets/default_avatar.png'),
        ),
      ],
    );
  }

  Widget _buildStats(ProfileViewModel vm) {
    return Column(
      children: [
        _statCard("Total Sessions", vm.totalSessionsCompleted, Icons.check_circle_outline, Colors.green),
        _statCard("Total Focus Time", formatMinutesToHours(vm.totalFocusTime), Icons.timer, Colors.purple),
        _statCard("Good Posture Time", formatMinutesToHours(vm.totalGoodPostureTime), Icons.accessibility, Colors.blue),
        _statCard("Least Breaks", vm.leastBreaks ?? 0, Icons.timer_off, Colors.red),
        _statCard("Posture Streak", "${vm.goodPostureStreak} days 🔥", Icons.local_fire_department, Colors.orange),
        _statCard("Consecutive Days", "${vm.consecutiveDaysUsed}", Icons.calendar_today, Colors.teal),
      ],
    );
  }

  Widget _statCard(String label, dynamic value, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value.toString(), style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildBadges(List<String> badges) {
    if (badges.isEmpty) return const SizedBox();

    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    String _getBadgeValue(String badgeKey) {
      switch (badgeKey) {
        case 'least_breaks':
          return profileVM.leastBreaks?.toString() ?? '-';
        case 'total_sessions_completed':
          return profileVM.totalSessionsCompleted.toString();
        case 'total_focus_time':
          return profileVM.totalFocusTime.toString();
        case 'good_posture_streak':
          return profileVM.goodPostureStreak.toString();
        case 'consecutive_days_used':
          return profileVM.consecutiveDaysUsed.toString();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Badges", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.map((badgeKey) {
            return Chip(
              label: Text(
                badgeKey.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              avatar: Icon(_getBadgeIcon(badgeKey), color: Colors.white),
              backgroundColor: Colors.lightGreen,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
      ],
    );
  }
}
