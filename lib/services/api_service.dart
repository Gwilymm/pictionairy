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
  /// Generates an image for a given game session and challenge.
  ///
  /// This function sends a POST request to the server to generate an image
  /// for the specified game session and challenge. It requires a valid
  /// authentication token to be included in the request headers.
  ///
  /// If the request is successful (status code 200), the function returns
  /// the URL of the generated image. If the request fails or the token is
  /// null, the function returns null.
  ///
  /// Parameters:
  /// - `gameSessionId`: The ID of the game session.
  /// - `challengeId`: The ID of the challenge.
  ///
  /// Returns:
  /// A `Future<String?>` that resolves to the URL of the generated image,
  /// or null if the request fails or the token is null.

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
        
        String teamColor = redTeam.length < 2 ? 'red' : 'blue';
        final response = await http.post(
          Uri.parse('$baseUrl/game_sessions/$sessionId/join'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'color': teamColor}),
        );

        if (response.statusCode == 200) {
          debugPrint('Added ${player['username']} to $teamColor team');
          if (teamColor == 'red') redTeam.add(1);
          else blueTeam.add(1);
        }
        
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        debugPrint('Error adding ${player['username']}: $e');
      }
    }

    // Reconnect original user
    try {
      final originalToken = await login('gwilym', 'azerty');
      if (originalToken != null) {
        debugPrint('Successfully reconnected original user (gwilym)');
        // Store the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', originalToken);
      } else {
        debugPrint('Failed to reconnect original user');
      }
    } catch (e) {
      debugPrint('Error reconnecting original user: $e');
    }

    // Verify final state
    final finalSessionDetails = await getGameSessionDetails(sessionId);
    debugPrint('Final session state: ${finalSessionDetails.body}');
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

