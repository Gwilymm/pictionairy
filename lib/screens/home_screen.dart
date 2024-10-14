// lib/screens/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pictionairy/screens/join_game_screen.dart';
import 'package:pictionairy/screens/start_game_screen.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/utils/colors.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = HomeController();
  String? connectedUser;

  @override
  void initState() {
    super.initState();
    _loadConnectedUser();
  }

  Future<void> _loadConnectedUser() async {
    final user = await _homeController.loadConnectedUser();
    setState(() {
      connectedUser = user;
    });
  }

  Future<void> _startGame() async {
    final sessionDetails = await _homeController.createAndJoinGameSession();

    if (sessionDetails != null && connectedUser != null) {
      // Parse game session details and navigate to StartGameScreen
      final gameSessionDetails = jsonDecode(sessionDetails) as Map<String, dynamic>;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartGameScreen(
            connectedUser: connectedUser!,
            sessionId: gameSessionDetails['session_id'],
            gameSession: gameSessionDetails,
          ),
        ),
      );
    } else {
      // Handle failure to create or join session
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create or join game session')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Piction.AI.ry'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: BubbleBackground.buildBubbles(),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    'Prêt à jouer ?',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choisissez une option ci-dessous pour commencer une partie ou rejoindre une partie existante.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Button to Start a Game
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: ElevatedButton.icon(
                      onPressed: connectedUser == null ? null : _startGame,
                      style: AppTheme.elevatedButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
                      ),
                      icon: const Icon(Icons.play_arrow, color: AppColors.buttonTextColor),
                      label: const Text(
                        'Commencer une partie',
                        style: AppTheme.buttonTextStyle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Button to Join a Game
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const JoinGameScreen()),
                        );
                      },
                      style: AppTheme.elevatedButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
                      ),
                      icon: const Icon(Icons.qr_code_scanner, color: AppColors.buttonTextColor),
                      label: const Text(
                        'Rejoindre une partie',
                        style: AppTheme.buttonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
