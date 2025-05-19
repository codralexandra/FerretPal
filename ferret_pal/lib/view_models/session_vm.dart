import 'package:flutter/material.dart';

import '../services/session_service.dart';

// Managing and notifying session state
class SessionViewModel extends ChangeNotifier{
  final SessionService _sessionService = SessionService();
  bool isSessionRunning = false;

  // Asynchronously starts the session
  Future<void> startSession() async {
    final success = await _sessionService.startSession();
    if(success){
      isSessionRunning = true;
      notifyListeners();
    } else{
      throw Exception('Failed to start session');
    }
  }

  // Asynchronously stops the session
  Future<void> stopSession() async {
    final success = await _sessionService.stopSession();
    if(success){
      isSessionRunning = false;
      notifyListeners();
    } else{
      throw Exception('Failed to stop session');
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
