import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// TO IMPLEMENT
/// Service class for server communication regarding session information
class SessionService{
  // Session routes on _baseUrl
  static const String _baseUrl = 'http://10.0.2.2:5000/session';

  // Asynchronously starts the session by calling the /session/start_session route
  Future<bool> startSession() async {
    final url = Uri.parse('$_baseUrl/start_session');
    return true;
  }

  // Asynchronously stops the session by calling the /session/stop_session route
  Future<bool> stopSession() async {
    final url = Uri.parse('$_baseUrl/stop_session');
    return true;
  }

  // Asynchronously saves the sensor values by calling the /session/save_values route
  Future<bool> saveValues() async {
    final url = Uri.parse('$_baseUrl/save_values');
    return true;
  }

  // Asynchronously saves the session data by calling the /session/save_values route
  Future<bool> saveSession() async {
    final url = Uri.parse('$_baseUrl/save_session');
    return true;
  }
}