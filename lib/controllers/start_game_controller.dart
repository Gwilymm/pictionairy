import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pictionairy/services/api_service.dart';

class StartGameController with ChangeNotifier {
  final Map<String, dynamic> gameSession;
  static const int maxPlayersPerTeam = 2;
  static const int minPlayers = 2;
  final Map<String, String> _playerNamesCache = {};

  StartGameController(this.gameSession);

  bool canStartGame(String userId) {
    return gameSession['gameStarterId'] == userId;
  }

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
    try {
      final sessionDetails = await ApiService.getGameSessionDetails(gameSession['id'].toString());
      debugPrint("Session details response: ${sessionDetails.body}"); // Debug log
      
      if (sessionDetails.statusCode != 200) {
        debugPrint("Failed to get session details: ${sessionDetails.statusCode}");
        return [[], []];
      }

      final data = jsonDecode(sessionDetails.body);
      
      // Extract player IDs from the response
      final List<dynamic> redTeamIds = data['red_team'] ?? [];
      final List<dynamic> blueTeamIds = data['blue_team'] ?? [];
      
      debugPrint("Red team IDs before conversion: $redTeamIds"); // Debug log
      debugPrint("Blue team IDs before conversion: $blueTeamIds"); // Debug log

      // Convert IDs to integers and fetch names
      final redTeamNames = await Future.wait(
        redTeamIds.map((id) => ApiService.fetchPlayerName(int.parse(id.toString())))
      );
      final blueTeamNames = await Future.wait(
        blueTeamIds.map((id) => ApiService.fetchPlayerName(int.parse(id.toString())))
      );

      debugPrint("Red team names: $redTeamNames"); // Debug log
      debugPrint("Blue team names: $blueTeamNames"); // Debug log

      return [redTeamNames, blueTeamNames];
    } catch (e, stackTrace) {
      debugPrint('Error getting teams: $e');
      debugPrint('Stack trace: $stackTrace');
      return [[], []];
    }
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

  Future<bool> hasMinimumPlayers() async {
    try {
      final teams = await getTeams();
      final totalPlayers = teams[0].length + teams[1].length;
      debugPrint('Total players: $totalPlayers'); // Debug log
      return totalPlayers >= minPlayers;
    } catch (e) {
      debugPrint('Error checking minimum players: $e');
      return false;
    }
  }

  Future<List<String>> _fetchPlayerNames(List<String> playerIds) async {
    List<String> names = [];
    for (String id in playerIds) {
      if (_playerNamesCache.containsKey(id)) {
        names.add(_playerNamesCache[id]!);
      } else {
        final name = await ApiService.fetchPlayerName(int.parse(id));
        _playerNamesCache[id] = name;
        names.add(name);
      }
    }
    return names;
  }
}
