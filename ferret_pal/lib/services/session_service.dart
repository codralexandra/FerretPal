import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Service class for server communication regarding session information
class SessionService{
  // Session routes on _baseUrl
  static const String _baseUrl = 'http://10.0.2.2:5000/session';

  // Asynchronously starts the session by calling the /session/start_session route
  Future<bool> startSession(String username) async {
    final url = Uri.parse('$_baseUrl/$username/start_session');
    try{
      final response = await http.post(url);
      return response.statusCode == 200;
    } catch (e){
      print('Error starting session: $e');
      return false;
    }
  }

  // Asynchronously stops the session by calling the /session/stop_session route
  Future<bool> stopSession(String username) async {
    final url = Uri.parse('$_baseUrl/$username/stop_session');
    try{
      final response = await http.post(url);
      return response.statusCode == 200;
    } catch (e){
      print('Error stopping session: $e');
      return false;
    }
  }

  Stream<bool> streamPostureStatus() async* {
    final client = http.Client();
    final request = http.Request('GET', Uri.parse('$_baseUrl/posture_stream'));
    final response = await client.send(request);

    if(response.statusCode != 200) {
      throw Exception('Failed to connect to posture stream.');
    }

    // Accumulate chunks and emit posture booleans
    final stream = response.stream.transform(utf8.decoder).transform(LineSplitter());
    await for (final line in stream){
      if(line.startsWith('data: ')){
        try{
          final jsonData = jsonDecode(line.substring(6));
          print('Received data from server: $jsonData');
          yield jsonData['is_good'] == true;
        } catch (e){
          print('Failed to parse posture data: $e');
        }
      }
    }
  }

  Future<Map<String, dynamic>> fetchLastSession(String username) async {
    final url = Uri.parse('$_baseUrl/$username/get_last_session');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load last session (status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching last session: $e');
      rethrow;
    }
  }

  Future<List<DateTime>> fetchAllSessionTimestamps(String username) async {
    final url = Uri.parse('$_baseUrl/$username/get_all_sessions');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['sessions'] as List)
            .map<DateTime>((s) => DateTime.parse(s))
            .toList();
      } else {
        throw Exception('Failed to load sessions (status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching all sessions: $e');
      rethrow;
    }
  }

  Future<bool> clearSessions(String username) async {
    final url = Uri.parse('$_baseUrl/$username/clear_sessions');
    try {
      final response = await http.post(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing sessions: $e');
      return false;
    }
  }
}