import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/controllers/challenge_form_controller.dart'; // Import ChallengeFormController
import 'package:provider/provider.dart'; // Import Provider
import 'package:pictionairy/services/api_service.dart'; // Import ApiService
import 'challenge_form_screen.dart';
import 'dart:convert'; // For encoding/decoding JSON

class ChallengeCreateScreen extends StatefulWidget {
  final String gameSessionId; // Add gameSessionId

  const ChallengeCreateScreen({super.key, required this.gameSessionId}); // Update constructor

  @override
  _ChallengeCreateScreenState createState() => _ChallengeCreateScreenState();
}

class _ChallengeCreateScreenState extends State<ChallengeCreateScreen> {
  List<Map<String, dynamic>> challenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges(); // Load stored challenges on init
  }

  // Load challenges from SharedPreferences
  // Load challenges from SharedPreferences (new structure)
Future<void> _loadChallenges() async {
  final prefs = await SharedPreferences.getInstance();
  final String? storedChallenges = prefs.getString('challenges');
  if (storedChallenges != null) {
    setState(() {
      challenges = List<Map<String, dynamic>>.from(
        jsonDecode(storedChallenges).map((e) => {
          'id': e['id'],
          'details': e['details'],
        }),
      );
    });
  }
}

// Save challenges to SharedPreferences (new structure)
Future<void> _saveChallenges() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(
    'challenges',
    jsonEncode(challenges.map((challenge) => {
          'id': challenge['id'],
          'details': challenge['details'],
        }).toList()),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to extend behind the AppBar
      appBar: AppBar(
        title: const Text('Saisie des challenges'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background with gradient
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
          // Bubble Background
          Positioned.fill(
            child: BubbleBackground.buildBubbles(),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];
                      if (challenge.isEmpty) {
                        return SizedBox.shrink(); // Don't create a card if there is no challenge
                      }
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: AppColors.backgroundSecondaryColor, // Styled using your theme
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Challenge ${index + 1}",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.primaryColor),
                                        onPressed: () {
                                          setState(() {
                                            challenges.removeAt(index); // Remove the challenge
                                          });
                                          _saveChallenges(); // Save changes after deletion
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          String? imageUrl = await Provider.of<ChallengeFormController>(context, listen: false)
                                              .generateImage(widget.gameSessionId, challenge['id']);
                                          if (imageUrl != null) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Image.network(imageUrl),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('Close'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Text('Generate Image'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Display the phrase in one line
                              Text(
                                "${challenge['firstToggle']} ${challenge['firstWord']} ${challenge['preposition']} ${challenge['secondToggle']} ${challenge['secondWord']}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),

                              // Forbidden words
                              Wrap(
                                spacing: 8.0,
                                children: (challenge['forbiddenWords'] as List<String>? ?? [])
                                    .map((word) => Chip(
                                  label: Text(word),
                                  backgroundColor: AppColors.teamRedColor,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final Map<String, dynamic>? result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChallengeFormScreen()),
                    );
                    if (result != null) {
                      setState(() {
                        challenges.add(result);
                      });
                      _saveChallenges();
                    }
                  },
                  style: AppTheme.elevatedButtonStyle,
                  child: const Text('Ajouter un challenge', style: AppTheme.buttonTextStyle),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    for (var challenge in challenges) {
                      Map<String, dynamic> formattedChallenge = {
                        "first_word": challenge['firstToggle'],
                        "second_word": challenge['firstWord'],
                        "third_word": challenge['preposition'],
                        "fourth_word": challenge['secondToggle'],
                        "fifth_word": challenge['secondWord'],
                        "forbidden_words": challenge['forbiddenWords'],
                      };

                      List<String> challengeIds = await ApiService.sendChallenges(widget.gameSessionId, formattedChallenge);
                      if (challengeIds.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Challenges sent successfully! IDs: ${challengeIds.join(', ')}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to send challenges')),
                        );
                      }
                    }
                  },
                  style: AppTheme.elevatedButtonStyle,
                  child: const Text('Envoyer les challenges', style: AppTheme.buttonTextStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
