import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:pictionairy/screens/join_game_screen.dart';
import 'package:pictionairy/screens/login_screen.dart';
import 'package:pictionairy/screens/start_game_screen.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/utils/colors.dart';
import '../controllers/home_controller.dart';
import '../controllers/login_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = HomeController();
  final LoginController _loginController = LoginController();

  String? connectedUser;
  int bubblePopCount = 0;

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
      final gameSessionDetails = jsonDecode(sessionDetails) as Map<String, dynamic>;
      debugPrint('Game session details: $gameSessionDetails');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StartGameScreen(
            connectedUser: connectedUser!,
            sessionId: gameSessionDetails['id'].toString(),
            gameSession: gameSessionDetails,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create or join game session')),
      );
    }
  }

  Future<void> _logout() async {
    await _loginController.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _incrementBubblePopCount() {
    setState(() {
      bubblePopCount++;
      if (bubblePopCount == 42) {
        _showHitchhikerModal();
      }
    });
  }

  void _showHitchhikerModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "La réponse ultime",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          content: const Text(
            "42 est la réponse à la grande question de la vie, de l'univers et de tout.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Saloprilopette !",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }


  void _resetBubblePopCount() {
    setState(() {
      bubblePopCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Piction.AI.ry',
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.secondaryColor),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dégradé en arrière-plan
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
          // Fond animé avec les bulles
          Positioned.fill(
            child:  BubbleBackground.buildBubbles(
              noOfBubbles: 30,
              isInteractive: true, // Activer l'interactivité
              onBubbleTapped: _incrementBubblePopCount, // Incrémenter le compteur
            ),
          ),

          // Autres contenus (texte, boutons, etc.)
          Padding(
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
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ElevatedButton.icon(
                    onPressed: connectedUser == null ? null : _startGame,
                    style: AppTheme.elevatedButtonStyle,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Commencer une partie'),
                  ),
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JoinGameScreen()),
                      );
                    },
                    style: AppTheme.elevatedButtonStyle,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Rejoindre une partie'),
                  ),
                ),
              ],
            ),
          ),
          // Affichage du compteur
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 16,
            right: 16,
            child: GlassContainer.clearGlass(
              height: MediaQuery.of(context).size.height * 0.15,
              borderRadius: BorderRadius.circular(16.0),
              blur: 12.0,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bulles éclatées : $bubblePopCount',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _resetBubblePopCount,
                    style: AppTheme.elevatedButtonStyle,
                    child: const Text('  Réinitialiser le compteur  '),
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
