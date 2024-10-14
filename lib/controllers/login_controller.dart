/// This controller handles the login functionality for the application.
///
/// It interacts with the UI to validate user inputs, communicates with the
/// [ApiService] to authenticate the user, and stores the logged-in user's details
/// using [SharedPreferencesUtil].
library;
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../utils/shared_preferences_util.dart';

class LoginController {
  /// Controller for the username input field.
  final TextEditingController usernameController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController passwordController = TextEditingController();

  /// Logs in the user using the provided [formKey] for input validation.
  ///
  /// First, the method validates the form using [formKey]. If validation passes,
  /// it proceeds to call [ApiService.login] with the entered username and password.
  ///
  /// If the login is successful, it retrieves the user details using [ApiService.getPlayerDetails]
  /// and saves them to shared preferences for later access. Returns `true` if the login and
  /// retrieval of user details are successful, otherwise returns `false`.
  ///
  /// Throws an error if [formKey] is not valid.
  ///
  /// - Parameter [formKey]: A [GlobalKey] used to validate the login form.
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

  /// Retrieves the currently connected user's details from shared preferences.
  ///
  /// This method returns a [Map] containing the user's information if available,
  /// otherwise returns `null`.
  ///
  /// - Returns: A [Map<String, dynamic>] with the user's details or `null` if no
  /// user is connected.
  Future<Map<String, dynamic>?> getConnectedUser() async {
    String? userJson = await SharedPreferencesUtil.getConnectedUser();
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  /// Retrieves the saved authentication token from shared preferences.
  ///
  /// This method is used to get the JWT token for authenticating API requests
  /// that require user authorization.
  ///
  /// - Returns: A [String] representing the user's JWT token or `null` if no token
  /// is saved.
  Future<String?> getToken() async {
    return await SharedPreferencesUtil.getToken();
  }

  /// Disposes the [TextEditingController] instances used for the username and password fields.
  ///
  /// This method must be called to prevent memory leaks when the controller is no longer needed.
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
