// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:pictionairy/screens/join_game_screen.dart';
import 'package:pictionairy/screens/start_game_screen.dart';
import 'package:pictionairy/utils/theme.dart'; // Import the theme
import 'package:pictionairy/utils/colors.dart'; // Import the colors
import 'package:pictionairy/utils/shared_preferences_util.dart'; // Import SharedPreferencesUtil

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? connectedUser;

  @override
  void initState() {
    super.initState();
    _loadConnectedUser();
  }

  Future<void> _loadConnectedUser() async {
    final user = await SharedPreferencesUtil.getConnectedUser();
    setState(() {
      connectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to extend behind the AppBar
      appBar: AppBar(
        title: const Text('Piction.AI.ry'),
        backgroundColor: Colors.transparent, // Make AppBar transparent to show the background
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Grape soda background with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.accentColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Animated Bubble Background using BubbleBackground class
          Positioned.fill(
            child: BubbleBackground.buildBubbles(), // Reusable bubble background
          ),

          // Main content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header or description text
                  const SizedBox(height: 100), // Adjusted for visual spacing
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
                    widthFactor: 0.8, // Adjust width to 80% of the parent width
                    child: ElevatedButton.icon(
                      onPressed: connectedUser == null
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StartGameScreen(connectedUser: connectedUser!),
                          ),
                        );
                      },
                      style: AppTheme.elevatedButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
                      ), // Use button style from theme
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
                    widthFactor: 0.8, // Adjust width to 80% of the parent width
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const JoinGameScreen()),
                        );
                      },
                      style: AppTheme.elevatedButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all(AppColors.buttonColor),
                      ), // Use button style from theme
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
