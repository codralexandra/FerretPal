import 'package:flutter/material.dart';

import '../services/session_service.dart';

// Managing and notifying session state
class SessionViewModel extends ChangeNotifier{
  final SessionService _sessionService = SessionService();

  // Asynchronously starts the session
  Future<void> startSession() async {
    try {
      await _sessionService.startSession();
      notifyListeners();
    } catch (e) {
      throw Exception('Error saving profile.');
    }
  }

  // Asynchronously stops the session
  Future<void> stopSession() async {
    try {
      await _sessionService.stopSession();
      notifyListeners();
    } catch (e) {
      throw Exception('Error saving profile.');
    }
  }

  // Asynchronously saves sensor values
  Future<void> saveValues() async {
    try {
      await _sessionService.saveValues();
      notifyListeners();
    } catch (e) {
      throw Exception('Error saving profile.');
    }
  }

  // Asynchronously saves the session
  Future<void> saveSession() async {
    try {
      await _sessionService.saveSession();
      notifyListeners();
    } catch (e) {
      throw Exception('Error saving profile.');
    }
  }
}
