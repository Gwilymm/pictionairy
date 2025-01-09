import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pictionairy/services/api_service.dart';

import '../screens/start_game_screen.dart';

class JoinGameController {
  static const int maxPlayersPerTeam = 2;

  Future<void> joinGame(BuildContext context, String sessionId,
      String connectedUser, Map<String, dynamic> gameSession) async {
    try {
      // Ajouter le joueur à une équipe
      await addPlayerToTeam(sessionId);

      // Naviguer vers StartGameScreen avec les paramètres nécessaires
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
      // Afficher une boîte de dialogue d'erreur en cas d'échec
      showErrorDialog(context, e.toString());
    }
  }

  Future<int> getTeamPlayerCount(String sessionId, String color) async {
    final response = await ApiService.getGameSessionDetails(sessionId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final teamPlayers = (color == 'red')
          ? List<String>.from(data['red_team_players'] ?? [])
          : List<String>.from(data['blue_team_players'] ?? []);
      return teamPlayers.length;
    } else {
      throw Exception('Impossible de récupérer les détails de la session');
    }
  }

  Future<void> addPlayerToTeam(String sessionId) async {
    // Récupérer le nombre de joueurs dans chaque équipe
    int redTeamCount = await getTeamPlayerCount(sessionId, 'red');
    int blueTeamCount = await getTeamPlayerCount(sessionId, 'blue');

    // Ajouter à l'équipe vide si une équipe a un joueur et l'autre est vide
    if (redTeamCount == 1 && blueTeamCount == 0) {
      await joinGameSession(sessionId, 'blue');
    } else if (blueTeamCount == 1 && redTeamCount == 0) {
      await joinGameSession(sessionId, 'red');
    } 
    // Si les deux équipes ont un joueur, choisir aléatoirement
    else if (redTeamCount == 1 && blueTeamCount == 1) {
      String selectedTeam = Random().nextBool() ? 'red' : 'blue';
      await joinGameSession(sessionId, selectedTeam);
    } 
    // Ajouter à une équipe en fonction de leur capacité
    else if (redTeamCount < maxPlayersPerTeam && blueTeamCount < maxPlayersPerTeam) {
      if (redTeamCount < blueTeamCount) {
        await joinGameSession(sessionId, 'red');
      } else {
        await joinGameSession(sessionId, 'blue');
      }
    } 
    // Les deux équipes sont pleines
    else if (redTeamCount >= maxPlayersPerTeam && blueTeamCount >= maxPlayersPerTeam) {
      throw Exception('Les deux équipes sont pleines');
    } else {
      throw Exception('Condition non prise en charge');
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
