import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://pictioniary.wevox.cloud/api';

  // Method to register a new player
  static Future<http.Response> createPlayer(
      String name, String password) async {
    final url = Uri.parse('$baseUrl/players');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'password': password}),
    );
    return response;
  }

  // Method to log in a player and store the JWT
  static Future<String?> login(String name, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token;
      }
    }
    return null; // Login failed or no token received
  }

  // Method to get player details by ID (Protected by JWT)
  static Future<http.Response> getPlayerDetails(String token) async {
    final token = await getToken();
    debugPrint('Token: $token');
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/me');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  // Fetch the player's name using the player ID
  static Future<String> fetchPlayerName(int playerId) async {
    try {
      final token = await getToken();
      if (token == null) return '<en attente>';

      final url = Uri.parse('$baseUrl/players/$playerId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final playerData = jsonDecode(response.body);
        return playerData['name'] ?? '<en attente>';
      }
      return '<en attente>';
    } catch (e) {
      debugPrint('Error fetching player name: $e');
      return '<en attente>';
    }
  }

  // Method to create a game session (Protected by JWT)
  static Future<String?> createGameSession() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/game_sessions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']?.toString(); // Safely convert and return the session ID
    } else {
      return null; // Creation failed
    }
  }

  // Method to get details of a game session by ID (Protected by JWT)
  static Future<http.Response> getGameSessionDetails(String sessionId) async {
    final token = await getToken();
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/game_sessions/$sessionId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  // Method to join a game session (Protected by JWT)
  static Future<http.Response> joinGameSession(
    String sessionId,
    String teamColor, {
    int? playerId,  // Add optional playerId parameter
  }) async {
    final token = await getToken();
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/game_sessions/$sessionId/join');
    final Map<String, dynamic> body = {
      'color': teamColor,
    };

    // Add playerId to body if provided
    if (playerId != null) {
      body['playerId'] = playerId;
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    
    debugPrint('Join Response for player $playerId: ${response.body}');
    return response;
  }

  // get the list of players in a game session
  static Future<List<String>> getGameSessionPlayers(String sessionId) async {
    final response = await getGameSessionDetails(sessionId);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final redTeamPlayers = List<String>.from(data['red_team_players']);
      final blueTeamPlayers = List<String>.from(data['blue_team_players']);
      return redTeamPlayers + blueTeamPlayers;
    } else {
      return [];
    }
  }

  // Method to leave a game session (Protected by JWT)
  static Future<http.Response> leaveGameSession(String sessionId, {int? playerId}) async {
    final token = await getToken();
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/game_sessions/$sessionId/leave');
    final Map<String, dynamic> body = {};
    
    if (playerId != null) {
      body['playerId'] = playerId;
    }

    final response = await http.post(  // Changed from get to post
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return response;
  }

  // Method to generate an image for a challenge
  static Future<String?> generateImage(String gameSessionId, String challengeId) async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/game_sessions/$gameSessionId/challenges/$challengeId/draw');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['imageUrl'];
    } else {
      return null;
    }
  }

  static Future<http.Response> getMyChallenges(String gameSessionId) async {
    final token = await getToken();
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/game_sessions/$gameSessionId/myChallenges');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  static Future<String?> generateImageWithPrompt(
    String gameSessionId,
    String challengeId,
    String prompt,
  ) async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/game_sessions/$gameSessionId/challenges/$challengeId/draw');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    }
    return null;
  }
 static Future<List<String>> sendChallenges(String gameSessionId, Map<String, dynamic> challenge) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/game_sessions/$gameSessionId/challenges'), // Fixed URL path
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(challenge),
      );

      debugPrint('Challenge response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        return ['success'];
      } else {
        debugPrint('Failed to send challenge: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error sending challenge: $e');
      return [];
    }
  }

  static Future<bool> updateGameStatus(String sessionId, String status) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/game_sessions/$sessionId/status');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      debugPrint("Update status response: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error updating game status: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> startGame(String sessionId) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final url = Uri.parse('$baseUrl/game_sessions/$sessionId/start');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("Start game response: ${response.statusCode}");
      debugPrint("Start game body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("Error starting game: $e");
      return null;
    }
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> addTestPlayers(String sessionId) async {
    final players = [
      {'username': 'moi3', 'password': 'azerty'},
      {'username': 'moi4', 'password': 'azerty'},
      {'username': 'moi5', 'password': 'azerty'}
    ];

    // Get current session state
    final sessionResponse = await getGameSessionDetails(sessionId);
    if (sessionResponse.statusCode != 200) {
      debugPrint('Failed to get session details');
      return;
    }

    final sessionData = jsonDecode(sessionResponse.body);
    var redTeam = List<dynamic>.from(sessionData['red_team'] ?? []);
    var blueTeam = List<dynamic>.from(sessionData['blue_team'] ?? []);

    debugPrint('Current red team size: ${redTeam.length}');
    debugPrint('Current blue team size: ${blueTeam.length}');

    // Add test players
    for (var player in players) {
      try {
        final token = await login(player['username']!, player['password']!);
        if (token == null) {
          debugPrint('Failed to login ${player['username']}');
          continue;
        }
        debugPrint('Successfully logged in ${player['username']}');
        
        // Determine team based on current sizes
        String teamColor = redTeam.length < 2 ? 'red' : 'blue';
        
        final joinResponse = await http.post(
          Uri.parse('$baseUrl/game_sessions/$sessionId/join'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'color': teamColor}),
        );

        if (joinResponse.statusCode == 200) {
          debugPrint('Added ${player['username']} to $teamColor team');
          if (teamColor == 'red') redTeam.add(1);
          else blueTeam.add(1);
        } else {
          debugPrint('Failed to add ${player['username']}: ${joinResponse.body}');
        }
        
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        debugPrint('Error adding ${player['username']}: $e');
      }
    }

    // Reconnect original user
    try {
      debugPrint('Reconnecting original user (gwilym)...');
      final originalToken = await login('gwilym', 'azerty');
      if (originalToken != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', originalToken);
        debugPrint('Successfully reconnected original user (gwilym)');
      } else {
        debugPrint('Failed to reconnect original user');
      }
    } catch (e) {
      debugPrint('Error reconnecting original user: $e');
    }

    // Verify final state
    final finalState = await getGameSessionDetails(sessionId);
    debugPrint('Final session state: ${finalState.body}');
  }
}

