// lib/utils/shared_preferences_util.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static Future<String?> getConnectedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('connectedUser');
  }

  static Future<void> setConnectedUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connectedUser', user);
  }
}