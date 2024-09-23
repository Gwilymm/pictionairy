import 'dart:convert';
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {

      return null;
    }

  }

  // Method to get player details by ID (Protected by JWT)
  static Future<http.Response> getPlayerDetails(String playerId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/players/$playerId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }
  static Future<String> fetchPlayerName(String playerId) async {
    try {
      final response = await getPlayerDetails(playerId); // Existing method to get player details
      if (response.statusCode == 20) {
        final playerData = jsonDecode(response.body);
        return playerData['name'] ?? '<en attente>'; // Return the player's name, or a placeholder
      } else {
        // Handle non-200 HTTP responses
        return '<en attente>'; // Placeholder for failed requests
      }
    } catch (e) {
      // Catch any exceptions, such as network errors
      print('Error fetching player name for $playerId: $e');
      return '<en attente>'; // Return a placeholder in case of an exception
    }
  }



  // Method to create a game session (Protected by JWT)
  static Future<String?> createGameSession() async {
    final url = Uri.parse('$baseUrl/game_sessions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await _getToken()}', // Assuming you have this method to get the JWT token
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final sessionId = data['id']; // Assuming 'id' is an integer

      if (sessionId is int) {
        return sessionId.toString(); // Convert int to String before returning
      }

      return null; // Handle unexpected responses
    } else {
      return null;
    }
  }


  // Method to get details of a game session by ID (Protected by JWT)
  static Future<http.Response> getGameSessionDetails(String sessionId) async {
    final token = await _getToken();
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
    final url = Uri.parse('$baseUrl/game_sessions/$sessionId/join');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'color': teamColor}),
    );
    return response;
  }

  // Method to leave a game session (Protected by JWT)
  static Future<http.Response> leaveGameSession(String sessionId) async {
    final token = await _getToken();
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
