import 'package:flutter/material.dart';
import 'package:pictionairy/services/api_service.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';

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
  late Future<List<String>> redTeam;
  late Future<List<String>> blueTeam;

  @override
  void initState() {
    super.initState();


  Future<String> _fetchPlayerNameSafely(int? playerId) async {
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
  debugPrint('Session ID: ${widget.gameSession}');
    redTeam = Future.wait([
      _fetchPlayerNameSafely(widget.gameSession['red_player_1']),
      _fetchPlayerNameSafely(widget.gameSession['red_player_2']),
    ]);
    blueTeam = Future.wait([
      _fetchPlayerNameSafely(widget.gameSession['blue_player_1']),
      _fetchPlayerNameSafely(widget.gameSession['blue_player_2']),
    ]);
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

                return Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 30.0), // Add padding to avoid overlap with app bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Équipe Rouge',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5), // Reduced height
                      Expanded(
                        child: ListView.builder(
                          itemCount: redTeamNames.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.redAccent.withOpacity(0.7),
                              child: ListTile(
                                title: Text(
                                  redTeamNames[index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10), // Reduced height
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Équipe Bleue',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5), // Reduced height
                      Expanded(
                        child: ListView.builder(
                          itemCount: blueTeamNames.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.blueAccent.withOpacity(0.7),
                              child: ListTile(
                                title: Text(
                                  blueTeamNames[index],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}