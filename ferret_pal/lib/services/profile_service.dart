import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  static const String _baseUrl = 'http://10.0.2.2:5000/user';

  Future<bool> saveProfile(String username, String displayName, String profilePicturePath) async {
    final url = Uri.parse('$_baseUrl/$username/save_profile');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'display_name': displayName,
        'profile_picture': profilePicturePath,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to save profile');
    }
  }

  Future<bool> profileExists(String username) async {
    final url = Uri.parse('$_baseUrl/$username/check_profile_exists');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body);
      return resData['exists'] ?? false;
    } else {
      throw Exception('Failed to check profile status');
    }
  }

  Future<Map<String, dynamic>> getInfo(String username) async {
    final url = Uri.parse('$_baseUrl/$username/get_user_info');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'display_name': data['display_name'],
        'profile_picture': data['profile_picture'],
      };
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<Map<String, dynamic>> getFullInfo(String username) async {
    final url = Uri.parse('$_baseUrl/$username/get_profile');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Failed to load full profile');
    }
  }

  Future<List<String>> getBadgePreferences(String username) async {
    final url = Uri.parse('$_baseUrl/$username/get_badge_preferences');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final badges = (data['badges'] as List<dynamic>).map((e) => e.toString()).toList();
      return badges;
    } else {
      throw Exception('Failed to load badge preferences');
    }
  }

  Future<void> saveBadgePreferences(String username, List<String> badges) async {
    final url = Uri.parse('$_baseUrl/$username/save_badge_preferences');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'badges': badges,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save badge preferences');
    }
  }
}
