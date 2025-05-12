import 'package:flutter/material.dart';
import 'dart:convert';

import '../services/profile_service.dart';

// Managing and notifying profile state
class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  String? displayName;
  String? profilePicturePath;

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

  /// Asynchronously checks if there's already a profile setup on server storage file
  Future<bool> profileExists() async {
    try {
      return await _profileService.profileExists();
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }
}