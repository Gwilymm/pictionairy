// lib/controllers/home_controller.dart
import 'dart:math';
import 'dart:convert';
import '../services/api_service.dart';
import '../utils/shared_preferences_util.dart';
import '../models/game_session.dart';  // Add this import
import 'package:flutter/material.dart';

class HomeController {
  Future<String?> loadConnectedUser() async {
    return await SharedPreferencesUtil.getConnectedUser();
  }

  Future<String?> createAndJoinGameSession() async {
    try {
      // Get connected user first
      final connectedUser = await loadConnectedUser();
      if (connectedUser == null) return null;
      
      // Parse the user JSON string
      final userMap = jsonDecode(connectedUser);
      final userId = userMap['id'];

      // Step 1: Create game session
      final sessionId = await ApiService.createGameSession();
      if (sessionId == null) {
        return null;
      }

      // Step 2: Randomly assign a team color
      final List<String> teamColors = ['red', 'blue'];
      final String randomTeam = teamColors[Random().nextInt(2)];

      // Step 3: Join the game session
      final joinResponse = await ApiService.joinGameSession(sessionId, randomTeam);
      if (joinResponse.statusCode != 200) {
        return null;
      }

      // Create a local game session object with the starter ID
      final gameSession = GameSession(
        id: sessionId,
        gameStarterId: userId,
        redTeamPlayers: randomTeam == 'red' ? [userMap['name']] : [],
        blueTeamPlayers: randomTeam == 'blue' ? [userMap['name']] : [],
      );

      // Return game session details as JSON string
      return jsonEncode(gameSession.toJson());
    } catch (e) {
      debugPrint('Error creating or joining session: $e');
      return null;
    }
  }

  /// Logs out the user by clearing the stored token and user details.
  Future<void> logout() async {
    await SharedPreferencesUtil.clearToken();
    await SharedPreferencesUtil.clearConnectedUser();
  }
}
