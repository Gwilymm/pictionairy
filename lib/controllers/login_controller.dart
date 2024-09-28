// lib/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../utils/shared_preferences_util.dart';

class LoginController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> login(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return false; // Validation failed
    }

    String username = usernameController.text;
    String password = passwordController.text;

    // Step 1: Login to get the token
    final token = await ApiService.login(username, password);

    if (token != null) {
      // Step 2: Retrieve user details after successful login
      final response = await ApiService.getPlayerDetails(username);
      if (response.statusCode == 200) {
        final userDetails = jsonDecode(response.body);

        // Save user details to SharedPreferences
        await SharedPreferencesUtil.setConnectedUser(json.encode(userDetails));
        return true;
      } else {
        return false; // Failed to retrieve user details
      }
    } else {
      return false; // Login failed
    }
  }

  Future<Map<String, dynamic>?> getConnectedUser() async {
    String? userJson = await SharedPreferencesUtil.getConnectedUser();
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  Future<String?> getToken() async {
    return await SharedPreferencesUtil.getToken();
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
