// lib/main.dart
import 'package:flutter/material.dart';
import 'utils/theme.dart'; // Importez le fichier de thème
import 'screens/home_screen.dart'; // Import the HomeScreen
import 'screens/login_screen.dart'; // Import the LoginScreen
import 'controllers/login_controller.dart'; // Import the LoginController

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piction.AI.ry',
      theme: AppTheme.theme,
      home: const SplashScreen(), // Use the SplashScreen as the entry point
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LoginController _loginController = LoginController();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    bool isLoggedIn = await _loginController.autoLogin();
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator while checking for auto-login
      ),
    );
  }
}