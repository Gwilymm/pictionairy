import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pictionairy/screens/join_game_screen.dart';
import 'package:pictionairy/screens/start_game_screen.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/shared_preferences_util.dart';
import 'package:pictionairy/utils/api_service.dart';
import 'dart:math';

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
                      onPressed: connectedUser == null
                          ? null
                          : () async {
                        // Step 1: Create game session
                        final sessionId = await ApiService.createGameSession();

                        if (sessionId != null) {
                          // Step 2: Randomly assign team color (red or blue)
                          final List<String> teamColors = ['red', 'blue'];
                          final String randomTeam = teamColors[Random().nextInt(2)];

                          // Step 3: Join the game session and get the response
                          final joinResponse = await ApiService.joinGameSession(sessionId, randomTeam);

                          if (joinResponse != null) {
                            // Step 4: Decode the JSON response into a Map
                            final gameSessionDetails = jsonDecode(joinResponse.body) as Map<String, dynamic>;

                            // Step 5: Navigate to StartGameScreen with session details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StartGameScreen(
                                  connectedUser: connectedUser!,
                                  sessionId: sessionId,
                                  gameSession: gameSessionDetails, // Pass session details
                                ),
                              ),
                            );
                          } else {
                            print("Failed to join the game session");
                          }
                        } else {
                          print("Failed to create game session");
                        }
                      },

                      style: AppTheme.elevatedButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all(AppColors.buttonColor),
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
                        backgroundColor: MaterialStateProperty.all(AppColors.buttonColor),
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
