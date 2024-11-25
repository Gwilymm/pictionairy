// join_game_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pictionairy/services/api_service.dart';

import '../screens/start_game_screen.dart';

class JoinGameController {
  static const int maxPlayersPerTeam = 2;

  Future<void> joinGame(BuildContext context, String sessionId,
      String connectedUser, Map<String, dynamic> gameSession) async {
    try {
      // Add player to the game session (assumed to be handled by this function)
      await addPlayerToTeam(sessionId);

      // Navigate to StartGameScreen with the necessary parameters
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StartGameScreen(
            connectedUser: connectedUser,
            sessionId: sessionId,
            gameSession: gameSession,
          ),
        ),
      );
    } catch (e) {
      // Show error dialog if joining fails
      showErrorDialog(context, e.toString());
    }
  }

  Future<bool> isTeamFull(String sessionId, String color) async {
    final response = await ApiService.getGameSessionDetails(sessionId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Utilisation de l'opérateur '??' pour éviter les erreurs si les listes sont nulles
      final teamPlayers = (color == 'red')
          ? List<String>.from(data['red_team_players'] ?? [])
          : List<String>.from(data['blue_team_players'] ?? []);

      return teamPlayers.length >= maxPlayersPerTeam;
    } else {
      throw Exception('Impossible de récupérer les détails de la session');
    }
  }

  Future<void> addPlayerToTeam(String sessionId) async {
    // Vérification de la capacité des équipes
    bool isRedTeamFull = await isTeamFull(sessionId, 'red');
    bool isBlueTeamFull = await isTeamFull(sessionId, 'blue');

    if (!isRedTeamFull) {
      await joinGameSession(sessionId, 'red');
    } else if (!isBlueTeamFull) {
      await joinGameSession(sessionId, 'blue');
    } else {
      throw Exception('Les deux équipes sont pleines');
    }
  }

  Future<Map<String, dynamic>> joinGameSession(
      String sessionId, String color) async {
    final response = await ApiService.joinGameSession(sessionId, color);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint(
          'Échec de la connexion : ${response.statusCode} - ${response.body}');
      throw Exception('Échec de la connexion à la session');
    }
  }

  Future<void> showErrorDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
