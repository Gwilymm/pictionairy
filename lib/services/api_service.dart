import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://pictioniary.wevox.cloud/api';

  // Method to register a new player
  static Future<http.Response> createPlayer(String name, String password) async {
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
    final token = await _getToken();
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
      final response = await getPlayerDetails(playerId);
      if (response.statusCode == 200) {
        final playerData = jsonDecode(response.body);
        return playerData['name'] ?? '<en attente>'; // Return the player's name, or a placeholder
      } else {
        return '<en attente>'; // Placeholder for failed requests
      }
    } catch (e) {
      print('Error fetching player name for $playerId: $e');
      return '<en attente>'; // Return a placeholder in case of an exception
    }
  }

  // Method to create a game session (Protected by JWT)
  static Future<String?> createGameSession() async {
    final token = await _getToken();
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
    final token = await _getToken();
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
  static Future<http.Response> joinGameSession(String sessionId, String teamColor) async {
    final token = await _getToken();
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/game_sessions/$sessionId/join');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'color': teamColor}),
    );
    debugPrint('Join Response: ${response.body}');
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
  static Future<http.Response> leaveGameSession(String sessionId) async {
    final token = await _getToken();
    if (token == null) return http.Response('Unauthorized', 401);

    final url = Uri.parse('$baseUrl/game_sessions/$sessionId/leave');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  // Helper method to get JWT token from SharedPreferences
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
