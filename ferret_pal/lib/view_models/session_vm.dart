import 'dart:async';

import 'package:flutter/material.dart';

import '../services/session_service.dart';

// Managing and notifying session state
class SessionViewModel extends ChangeNotifier{
  final SessionService _sessionService = SessionService();
  bool isSessionRunning = false;

  final StreamController<bool> _postureStreamController = StreamController<bool>.broadcast();
  Stream<bool> get postureStream => _postureStreamController.stream;

  StreamSubscription<bool>? _postureSubscription;

  Map<String,dynamic>? _lastSession;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get lastSession => _lastSession;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Asynchronously starts the session
  Future<void> startSession(String username) async {
    final success = await _sessionService.startSession(username);
    if(success){
      isSessionRunning = true;
      notifyListeners();

      // Listen for posture updates
      _postureSubscription = _sessionService.streamPostureStatus().listen(
            (isGood) => _postureStreamController.add(isGood),
            onError: (e) => print('Posture stream error: $e'),
      );
    } else{
      throw Exception('Failed to start session');
    }
  }

  // Asynchronously stops the session
  Future<void> stopSession(String username) async {
    final success = await _sessionService.stopSession(username);
    if(success){
      isSessionRunning = false;
      _postureSubscription?.cancel();
      _postureStreamController.add(false);
      notifyListeners();
    } else{
      throw Exception('Failed to stop session');
    }
  }

  // Asynchronously load the last session data
  Future<Map<String, dynamic>> loadLastSession(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastSession = await _sessionService.fetchLastSession(username);
      return _lastSession!; // or return a default {} if null safety is an issue
    } catch (e) {
      _error = e.toString();
      rethrow; // Optional: rethrow if the UI needs to handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose(){
    _postureSubscription?.cancel();
    _postureStreamController.close();
    super.dispose();
  }
}
