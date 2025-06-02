import 'package:flutter/material.dart';
import 'dart:convert';

import '../services/profile_service.dart';

// Managing and notifying profile state
class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

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

  /// Asynchronously saves the profile setup on server storage file
  Future<void> saveProfile(String displayName, String profilePicturePath) async {
    try {
      await _profileService.saveProfile(displayName, profilePicturePath);
      this.displayName = displayName;
      this.profilePicturePath = profilePicturePath;
      // Notify the screen that the profile has been saved so that the user can be
      // redirected to the main_dash
      notifyListeners();
    } catch (e) {
      throw Exception('Error saving profile.');
    }
  }

  /// Asynchronously returns the saved user information from server storage file
  Future<bool> getInfo() async {
    try {
      final data = await _profileService.getInfo();
      displayName = data['display_name'];
      profilePicturePath = data['profile_picture'];
      // Notify that the data has been received
      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading profile: $e');
      return false;
    }
  }
  /// Asynchronously returns the full saved user information from server storage file
  Future<bool> getFullInfo() async {
    try {
      final data = await _profileService.getFullInfo();

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

  /// Asynchronously checks if there's already a profile setup on server storage file
  Future<bool> profileExists() async {
    try {
      return await _profileService.profileExists();
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }

  /// Fetches badge preferences from server and updates local state
  Future<List<String>> getBadgePreferences() async {
    try {
      final badges = await _profileService.getBadgePreferences();
      selectedBadges = badges;
      notifyListeners();
      return selectedBadges;
    } catch (e) {
      print('Error fetching badge preferences: $e');
      return [];
    }
  }

  /// Saves badge preferences to server and updates local state
  Future<void> saveBadgePreferences(List<String> badges) async {
    try {
      await _profileService.saveBadgePreferences(badges);
      selectedBadges = badges;
      notifyListeners();
    } catch (e) {
      print('Error saving badge preferences: $e');
      throw Exception('Failed to save badge preferences');
    }
  }
}