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

      // Step 2: Join as game starter
      final joinResponse = await ApiService.joinGameSession(sessionId, 'red');
      if (joinResponse.statusCode != 200) {
        return null;
      }

      // Create game session object with all players
      final gameSession = GameSession(
        id: sessionId,
        gameStarterId: userId,
        redTeamPlayers: [userMap['name']], // Game starter is always in red team
        blueTeamPlayers: [],
      );

      // Return game session details as JSON string
      return jsonEncode(gameSession.toJson());
    } catch (e) {
      debugPrint('Error in createAndJoinGameSession: $e');
      return null;
    }
  }

  /// Logs out the user by clearing the stored token and user details.
  Future<void> logout() async {
    await SharedPreferencesUtil.clearToken();
    await SharedPreferencesUtil.clearConnectedUser();
  }
}
