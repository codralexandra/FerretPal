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

  // Asynchronously starts the session
  Future<void> startSession() async {
    final success = await _sessionService.startSession();
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
  Future<void> stopSession() async {
    final success = await _sessionService.stopSession();
    if(success){
      isSessionRunning = false;
      _postureSubscription?.cancel();
      _postureStreamController.add(false);
      notifyListeners();
    } else{
      throw Exception('Failed to stop session');
    }
  }

  @override
  void dispose(){
    _postureSubscription?.cancel();
    _postureStreamController.close();
    super.dispose();
  }
}
