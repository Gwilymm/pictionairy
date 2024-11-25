import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ChallengeFormController with ChangeNotifier {
  List<String> forbiddenWords = [];

  String? validateWord(String value) {
    if (value.isEmpty) {
      return 'Ce champ ne peut pas être vide';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Seules les lettres et espaces sont autorisés';
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? challenges = prefs.getStringList('challenges');
    if (challenges != null) {
      return challenges.map((challenge) {
        return jsonDecode(challenge) as Map<String, dynamic>;
      }).toList();
    }
    return [];
  }

  Future<void> saveChallenges(List<Map<String, dynamic>> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedChallenges = challenges.map((challenge) {
      return jsonEncode(challenge);
    }).toList();
    await prefs.setStringList('challenges', encodedChallenges);
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
