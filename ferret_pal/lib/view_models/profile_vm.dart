import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  String username = "";
  String? displayName;
  String? profilePicturePath;
  int? leastBreaks;
  int totalSessionsCompleted = 0;
  int totalFocusTime = 0;
  int totalGoodPostureTime = 0;
  int goodPostureStreak = 0;
  List<String> milestones = [];
  String? lastAchievementUnlocked;
  String? firstSessionDate;
  int consecutiveDaysUsed = 0;

  List<String> selectedBadges = [];

  void setUsername(String uname) {
    username = uname;
  }

  Future<void> saveProfile(String displayName, String profilePicturePath) async {
    if (username == null) throw Exception("Username not set.");
    try {
      await _profileService.saveProfile(username!, displayName, profilePicturePath);
      this.displayName = displayName;
      this.profilePicturePath = profilePicturePath;
      notifyListeners();
    } catch (e) {
      throw Exception('Error saving profile.');
    }
  }

  Future<bool> getInfo() async {
    if (username == null) throw Exception("Username not set.");
    try {
      final data = await _profileService.getInfo(username!);
      displayName = data['display_name'];
      profilePicturePath = data['profile_picture'];
      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading profile: $e');
      return false;
    }
  }

  Future<bool> getFullInfo() async {
    if (username == null) throw Exception("Username not set.");
    try {
      final data = await _profileService.getFullInfo(username!);

      displayName = data['display_name'];
      profilePicturePath = data['profile_picture'];
      leastBreaks = data['least_breaks'];
      totalSessionsCompleted = data['total_sessions_completed'];
      totalFocusTime = data['total_focus_time'];
      totalGoodPostureTime = data['total_good_posture_time'];
      goodPostureStreak = data['good_posture_streak'];
      milestones = List<String>.from(data['milestones']);
      lastAchievementUnlocked = data['last_achievement_unlocked'];
      firstSessionDate = data['first_session_date'];
      consecutiveDaysUsed = data['consecutive_days_used'];

      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading full profile: $e');
      return false;
    }
  }

  Future<bool> profileExists() async {
    if (username == null) throw Exception("Username not set.");
    try {
      return await _profileService.profileExists(username!);
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }

  Future<List<String>> getBadgePreferences() async {
    if (username == null) throw Exception("Username not set.");
    try {
      final badges = await _profileService.getBadgePreferences(username!);
      selectedBadges = badges;
      notifyListeners();
      return selectedBadges;
    } catch (e) {
      print('Error fetching badge preferences: $e');
      return [];
    }
  }

  Future<void> saveBadgePreferences(List<String> badges) async {
    if (username == null) throw Exception("Username not set.");
    try {
      await _profileService.saveBadgePreferences(username!, badges);
      selectedBadges = badges;
      notifyListeners();
    } catch (e) {
      print('Error saving badge preferences: $e');
      throw Exception('Failed to save badge preferences');
    }
  }
}
