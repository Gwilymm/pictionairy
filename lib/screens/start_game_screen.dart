// lib/screens/start_game_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pictionairy/utils/colors.dart'; // Import your color utilities
import 'package:pictionairy/utils/theme.dart'; // Import BubbleBackground from theme.dart

class StartGameScreen extends StatelessWidget {
  final String connectedUser;

  const StartGameScreen({Key? key, required this.connectedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String joke = "Why don't scientists trust atoms? Because they make up everything!";

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to extend behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent to show background
        elevation: 1,
        title: const Text(
          'Composition des équipes',
          style: TextStyle(color: Colors.black), // Title color
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              16.0, // Left padding
              MediaQuery.of(context).padding.top + kToolbarHeight + 16.0, // Top padding adjusted for AppBar and status bar
              16.0, // Right padding
              16.0, // Bottom padding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Blue
                const Text(
                  'Equipe Bleue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTeamContainer(
                  players: [connectedUser, '<en attente>'],
                  color: AppColors.teamBlueColor, // Use theme color
                ),
                const SizedBox(height: 30),

                // Team Red
                const Text(
                  'Equipe Rouge',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTeamContainer(
                  players: ['<en attente>', '<en attente>'],
                  color: AppColors.teamRedColor // Use theme color
                ),
                const Spacer(),

                // QR Code with a joke
                Center(
                  child: QrImageView(
                    data: joke,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 20),

                // Footer Message
                const Center(
                  child: Text(
                    'La partie sera lancée automatiquement une fois les joueurs au complet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build team container
  Widget _buildTeamContainer({required List<String> players, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: players
            .map((player) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            player,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ))
            .toList(),
      ),
    );
  }
}
