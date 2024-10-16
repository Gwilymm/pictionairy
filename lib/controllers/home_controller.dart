// lib/controllers/home_controller.dart
import 'dart:math';
import '../services/api_service.dart';
import '../utils/shared_preferences_util.dart';

class HomeController {
  Future<String?> loadConnectedUser() async {
    return await SharedPreferencesUtil.getConnectedUser();
  }

  Future<String?> createAndJoinGameSession() async {
    try {
      // Step 1: Create game session
      final sessionId = await ApiService.createGameSession();
      if (sessionId == null) {
        return null;
      }

      // Step 2: Randomly assign a team color (red or blue)
      final List<String> teamColors = ['red', 'blue'];
      final String randomTeam = teamColors[Random().nextInt(2)];

      // Step 3: Join the game session
      final joinResponse = await ApiService.joinGameSession(sessionId, randomTeam);
      if ( joinResponse.statusCode != 200) {
        return null;
      }

      // Return game session details as JSON string
      return joinResponse.body;
    } catch (e) {
      print('Error creating or joining session: $e');
      return null;
    }
  }
  /// Logs out the user by clearing the stored token and user details.
  Future<void> logout() async {
    await SharedPreferencesUtil.clearToken();
    await SharedPreferencesUtil.clearConnectedUser();
  }
}
