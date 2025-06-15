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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
        title: Text('Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: profileVM.profilePicturePath != null
                  ? FileImage(File(profileVM.profilePicturePath!))
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
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
    );
  }

  Widget _buildStats(ProfileViewModel vm) {
    return Column(
      children: [
        _statTile("Total Sessions", vm.totalSessionsCompleted),
        _statTile("Total Focus Time", "${vm.totalFocusTime} min"),
        _statTile("Good Posture Time", "${vm.totalGoodPostureTime} min"),
        _statTile("Least Breaks", vm.leastBreaks ?? 0),
        _statTile("Posture Streak", "${vm.goodPostureStreak} days"),
        _statTile("Consecutive Days", "${vm.consecutiveDaysUsed}"),
      ],
    );
  }

  Widget _statTile(String label, dynamic value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(value.toString()),
    );
  }

  Widget _buildBadges(List<String> badges) {
    if (badges.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Badges", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.map((badge) => Chip(label: Text(badge))).toList(),
        ),
      ],
    );
  }
}
