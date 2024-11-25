// start_game_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pictionairy/controllers/start_game_controller.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:glass_kit/glass_kit.dart';
import 'dart:async'; // Add this line
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Add this line

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
  late StartGameController _controller;
  late StreamController<List<List<String>>>
      _teamsStreamController; // Add this line
  BannerAd? _bannerAd; // Add this line

  @override
  void initState() {
    super.initState();
    _controller = StartGameController(widget.gameSession);
    _teamsStreamController =
        StreamController<List<List<String>>>(); // Add this line
    _startAutoRefresh(); // Add this line
     // Add this line
  }

  @override
  void dispose() {
    _teamsStreamController.close(); // Add this line
    _bannerAd?.dispose(); // Add this line
    super.dispose();
  }

  void _startAutoRefresh() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final teams = await _controller.getTeams();
      if (mounted) {
        _teamsStreamController.add(teams);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Composition des Équipes',
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Arrière-plan avec un dégradé moderne
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
              child: BubbleBackground.buildBubbles(),
            ),
            // Contenu principal enveloppé dans un SafeArea
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<List<List<String>>>(
                  stream: _teamsStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Erreur lors du chargement des noms des joueurs',
                          style: TextStyle(color: AppColors.secondaryColor),
                        ),
                      );
                    }

                    final redTeamNames = snapshot.data![0];
                    final blueTeamNames = snapshot.data![1];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cartes des équipes avec hauteur adaptative
                        Expanded(
                          child: _buildTeamCard(
                            'Équipe Rouge',
                            redTeamNames,
                            AppColors.teamRedColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _buildTeamCard(
                            'Équipe Bleue',
                            blueTeamNames,
                            AppColors.teamBlueColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // QR Code et bouton
                        Column(
                          children: [
                            Text(
                              'Inviter des joueurs',
                              style: TextStyle(
                                color: AppColors.secondaryColor.withOpacity(0.8),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                _showQRCodeModal(context);
                              },
                              child: Hero(
                                tag: 'qrCodeHero',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.secondaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(
                                      Icons.qr_code,
                                      size: 80,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Afficher le QR code',
                              style: TextStyle(
                                color: AppColors.secondaryColor.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bouton "Commencer"
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await _controller.addPlayerToTeam(widget.sessionId);
                              setState(() {}); // Actualiser l'interface utilisateur
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Commencer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Annonce publicitaire en bas
            if (_bannerAd != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Séparation claire entre le bouton et l'annonce
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await _controller.addPlayerToTeam(widget.sessionId);
                            setState(() {}); // Actualiser l'interface utilisateur
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Commencer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }





  Widget _buildTeamCard(
      String teamName, List<String> teamMembers, Color color,
      {double maxHeight = 140}) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: GlassContainer.clearGlass(
        borderRadius: BorderRadius.circular(16),
        blur: 15.0,
        borderColor: color.withOpacity(0.5),
        borderWidth: 2.0,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teamName,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: teamMembers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.7),
                        child: Text(
                          teamMembers[index][0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        teamMembers[index],
                        style: const TextStyle(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showQRCodeModal(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Hero(
              tag: 'qrCodeHero',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: QrImageView(
                    data: widget
                        .sessionId, // Assurez-vous que sessionId est bien utilisé ici
                    version: QrVersions.auto,
                    size: screenSize.width * 0.6,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
