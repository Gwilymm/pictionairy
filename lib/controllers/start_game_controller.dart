import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pictionairy/services/api_service.dart';

class StartGameController with ChangeNotifier {
  final Map<String, dynamic> gameSession;
  static const int maxPlayersPerTeam = 2;

  StartGameController(this.gameSession);

  Future<String> _fetchPlayerNameSafely(int? playerId) async {
    if (playerId == null) {
      return 'No Player';
    }
    try {
      final playerName = await ApiService.fetchPlayerName(playerId);
      return playerName.isNotEmpty ? playerName : '<Player not connected>';
    } catch (e) {
      return '<Error fetching player name>';
    }
  }

  Future<List<String>> getRedTeam() async {
    return Future.wait([
      _fetchPlayerNameSafely(gameSession['red_player_1']),
      _fetchPlayerNameSafely(gameSession['red_player_2']),
    ]);
  }

  Future<List<String>> getBlueTeam() async {
    return Future.wait([
      _fetchPlayerNameSafely(gameSession['blue_player_1']),
      _fetchPlayerNameSafely(gameSession['blue_player_2']),
    ]);
  }

  Future<List<List<String>>> getTeams() async {
    // Fetch the latest game session details
    final updatedGameSession = await _getUpdatedGameSession();
    final redTeam = await Future.wait([
      _fetchPlayerNameSafely(updatedGameSession['red_player_1']),
      _fetchPlayerNameSafely(updatedGameSession['red_player_2']),
    ]);
    final blueTeam = await Future.wait([
      _fetchPlayerNameSafely(updatedGameSession['blue_player_1']),
      _fetchPlayerNameSafely(updatedGameSession['blue_player_2']),
    ]);
    return [redTeam, blueTeam];
  }

  Future<Map<String, dynamic>> _getUpdatedGameSession() async {
    final response =
        await ApiService.getGameSessionDetails(gameSession['id'].toString());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve updated game session details');
    }
  }

  Future<Map<String, dynamic>> joinGameSession(
      String sessionId, String color) async {
    final response = await ApiService.joinGameSession(sessionId, color);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to join game session');
    }
  }

  Future<bool> isTeamFull(String color) async {
    List<String> team;
    if (color == 'red') {
      team = await getRedTeam();
    } else if (color == 'blue') {
      team = await getBlueTeam();
    } else {
      throw Exception('Invalid team color');
    }
    return team.length >= maxPlayersPerTeam;
  }

  Future<void> addPlayerToTeam(String sessionId) async {
    final redTeam = await getRedTeam();
    final blueTeam = await getBlueTeam();

    if (redTeam.length < maxPlayersPerTeam) {
      await joinGameSession(sessionId, 'red');
    } else if (blueTeam.length < maxPlayersPerTeam) {
      await joinGameSession(sessionId, 'blue');
    } else {
      throw Exception('Both teams are full');
    }
  }
}
