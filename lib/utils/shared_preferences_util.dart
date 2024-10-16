// lib/utils/shared_preferences_util.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static const String _tokenKey = "token";
  static const String _connectedUserKey = "connectedUser";

  // Store JWT Token
  static Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get JWT Token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Store Connected User Details
  static Future<void> setConnectedUser(String userJson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_connectedUserKey, userJson);
  }

  // Get Connected User Details
  static Future<String?> getConnectedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_connectedUserKey);
  }

  // Clear All Data (for logout purposes)
  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void>clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void>clearConnectedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_connectedUserKey);
  }
}
