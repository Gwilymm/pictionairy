import 'package:pictionairy/services/api_service.dart';
import 'package:flutter/foundation.dart';

class StartGameController with ChangeNotifier {
  final Map<String, dynamic> gameSession;

  StartGameController(this.gameSession);

  Future<String> _fetchPlayerNameSafely(int? playerId) async {
    if (playerId == null) {
      return '<Player not connected>';
    }
    try {
      final playerName = await ApiService.fetchPlayerName(playerId);
      return playerName.isNotEmpty ? playerName : '<Player not connected>';
    } catch (e) {
      return '<Error fetching player name>';
    }
  }

  Future<List<String>> getRedTeam() {
    return Future.wait([
      _fetchPlayerNameSafely(gameSession['red_player_1']),
      _fetchPlayerNameSafely(gameSession['red_player_2']),
    ]);
  }

  Future<List<String>> getBlueTeam() {
    return Future.wait([
      _fetchPlayerNameSafely(gameSession['blue_player_1']),
      _fetchPlayerNameSafely(gameSession['blue_player_2']),
    ]);
  }
}
