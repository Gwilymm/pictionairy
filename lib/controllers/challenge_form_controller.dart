import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pictionairy/services/api_service.dart';

class ChallengeFormController with ChangeNotifier {
  List<String> forbiddenWords = [];

  /// Validates a given word to ensure it meets specific criteria.
  /// 
  /// This function checks if the provided word is not empty and contains only
  /// letters (including accented characters) and spaces.
  /// 
  /// - Parameter value: The word to be validated.
  /// - Returns: A string containing an error message if the validation fails,
  ///   or `null` if the validation is successful.
  String? validateWord(String value) {
    if (value.isEmpty) {
      return 'Ce champ ne peut pas être vide';
    } else if (!RegExp(r'^[a-zA-Z\s\u00C0-\u017F]+$').hasMatch(value)) {
      return 'Seules les lettres et espaces sont autorisés';
    }
    return null;
  }

  /// Loads the list of challenges from shared preferences.
  ///
  /// This method retrieves the challenges stored in the shared preferences
  /// under the key 'challenges'. If no challenges are found or the stored
  /// data is empty, it returns an empty list. Otherwise, it decodes the
  /// JSON string into a list of maps, where each map represents a challenge.
  ///
  /// Returns a [Future] that completes with a list of maps, where each map
  /// contains the challenge data.
  Future<List<Map<String, dynamic>>> loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesData = prefs.getString('challenges');
    if (challengesData == null || challengesData.isEmpty) {
      return [];
    }
    final List<dynamic> challengesList = jsonDecode(challengesData);
    return challengesList.map((challenge) {
      return challenge as Map<String, dynamic>;
    }).toList();
  }

  Future<void> saveChallenges(List<Map<String, dynamic>> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedChallenges = challenges.map((challenge) {
      return jsonEncode(challenge);
    }).toList();
    await prefs.setStringList('challenges', encodedChallenges);
  }

  Future<String?> generateImage(String gameSessionId, String challengeId) async {
    return await ApiService.generateImage(gameSessionId, challengeId);
  }

  void addForbiddenWord(String word) {
    forbiddenWords.add(word);
    notifyListeners();
  }

  void removeForbiddenWord(String word) {
    forbiddenWords.remove(word);
    notifyListeners();
  }
}
