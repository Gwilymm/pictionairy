import 'package:flutter/material.dart';
import 'package:pictionairy/controllers/start_game_controller.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:provider/provider.dart';

class StartGameScreen extends StatefulWidget {
  final String connectedUser;
  final String sessionId;
  final Map<String, dynamic> gameSession;

  const StartGameScreen({
    super.key,
    required this.connectedUser,
    required this.sessionId,
    required this.gameSession,
  });

  @override
  _StartGameScreenState createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  late StartGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StartGameController(widget.gameSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: const Text(
          'Composition des Équipes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          Positioned.fill(child: BubbleBackground.buildBubbles()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<List<String>>>(
              future: Future.wait([
                _controller.getRedTeam(),
                _controller.getBlueTeam(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erreur lors du chargement des noms des joueurs'),
                  );
                }

                final redTeamNames = snapshot.data![0];
                final blueTeamNames = snapshot.data![1];

                return Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTeamSection('Équipe Rouge', redTeamNames, Colors.redAccent),
                      const SizedBox(height: 10),
                      _buildTeamSection('Équipe Bleue', blueTeamNames, Colors.blueAccent),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(String teamName, List<String> teamMembers, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              teamName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                return Card(
                  color: color.withOpacity(0.7),
                  child: ListTile(
                    title: Text(
                      teamMembers[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
