import 'package:flutter/material.dart';
import 'package:pictionairy/utils/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'challenge_create_screen.dart';

class StartGameScreen extends StatefulWidget {
  final String connectedUser;
  final String sessionId;
  final Map<String, dynamic> gameSession;

  const StartGameScreen({
    Key? key,
    required this.connectedUser,
    required this.sessionId,
    required this.gameSession,
  }) : super(key: key);

  @override
  _StartGameScreenState createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  late Future<List<String>> redTeam;
  late Future<List<String>> blueTeam;

  @override
  void initState() {
    super.initState();
    redTeam = Future.wait([
      _fetchPlayerNameSafely(widget.gameSession['red_player_1']),
      _fetchPlayerNameSafely(widget.gameSession['red_player_2']),
    ]);
    blueTeam = Future.wait([
      _fetchPlayerNameSafely(widget.gameSession['blue_player_1']),
      _fetchPlayerNameSafely(widget.gameSession['blue_player_2']),
    ]);
  }

  Future<String> _fetchPlayerNameSafely(String? playerId) async {
    if (playerId == null) {
      return '<Player not connected>'; // Return a placeholder if player ID is null
    }
    try {
      final playerName = await ApiService.fetchPlayerName(playerId);
      return playerName.isNotEmpty ? playerName : '<Player not connected>';
    } catch (e) {
      return '<Error fetching player name>'; // Return an error message in case of an exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: const Text(
          'Composition des équipes',
          style: TextStyle(color: Colors.black),
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
              future: Future.wait([redTeam, blueTeam]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erreur lors du chargement des noms des joueurs'),
                  );
                }

                final redTeamNames = snapshot.data![0]; // Red team names
                final blueTeamNames = snapshot.data![1]; // Blue team names

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Équipe Rouge',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(redTeamNames.join(", ")),
                    const SizedBox(height: 20),
                    const Text(
                      'Équipe Bleue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(blueTeamNames.join(", ")),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
