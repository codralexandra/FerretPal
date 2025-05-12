import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service class for server communication
class ProfileService {
  // Server running on _baseUrl
  static const String _baseUrl = 'http://10.0.2.2:5000';

  // Asynchronously saves the user data by calling the /save_profile route
  Future<bool> saveProfile(String displayName, String profilePicturePath) async {
    final url = Uri.parse('$_baseUrl/save_profile');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      // Parse the data into a jsonBody
      body: jsonEncode({
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

  // Asynchronously checks if a user profile already exists in server storage file
  // by calling the /check_profile_exists route
  Future<bool> profileExists() async {
    final url = Uri.parse('$_baseUrl/check_profile_exists');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> resData = jsonDecode(response.body);
      return resData['exists'] ?? false;
    } else {
      throw Exception('Failed to check profile status');
    }
  }

  // Asynchronously returns the saved user data from server storage file by calling
  // the /get_user_info route
  Future<Map<String, dynamic>> getInfo() async {
    final url = Uri.parse('$_baseUrl/get_user_info');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the user data from the jsonBody received
      final data = jsonDecode(response.body);
      return {
        'display_name': data['display_name'],
        'profile_picture': data['profile_picture'],
      };
    } else {
      throw Exception('Failed to load user info');
    }
  }
}
