import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/controllers/challenge_form_controller.dart'; // Import ChallengeFormController
import 'package:provider/provider.dart'; // Import Provider
import 'package:pictionairy/services/api_service.dart'; // Import ApiService
import 'challenge_form_screen.dart';
import 'dart:convert'; // For encoding/decoding JSON
import 'package:pictionairy/screens/drawing_challenges_screen.dart';

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
    _addTestPlayersChallenges(); // Add this line
    _addGwilymChallenges(); // Add this line
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

Future<void> _addTestPlayersChallenges() async {
  final testPlayers = [
    {'username': 'moi3', 'password': 'azerty'},
    {'username': 'moi4', 'password': 'azerty'},
    {'username': 'moi5', 'password': 'azerty'}
  ];

  // Predefined challenges for test players
  final challenges = [
    {
      "first_word": "une",
      "second_word": "poule",
      "third_word": "sur",
      "fourth_word": "un",
      "fifth_word": "mur",
      "forbidden_words": ["volaille", "brique", "poulet"]
    },
    {
      "first_word": "un",
      "second_word": "chat",
      "third_word": "dans",
      "fourth_word": "une",
      "fifth_word": "boite",
      "forbidden_words": ["carton", "felin", "miaou"]
    },
    {
      "first_word": "un",
      "second_word": "chien",
      "third_word": "sur",
      "fourth_word": "une",
      "fifth_word": "plage",
      "forbidden_words": ["sable", "mer", "aboyer"]
    }
  ];

  for (var player in testPlayers) {
    try {
      // Login as test player
      final token = await ApiService.login(player['username']!, player['password']!);
      if (token == null) {
        debugPrint('Failed to login ${player['username']}');
        continue;
      }
      debugPrint('Successfully logged in as ${player['username']}');

      // Send three challenges for each test player
      for (var challenge in challenges) {
        final response = await ApiService.sendChallenges(widget.gameSessionId, challenge);
        debugPrint('Challenge sent for ${player['username']}: $response');
      }

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Error processing challenges for ${player['username']}: $e');
    }
  }

  // Reconnect original user
  try {
    debugPrint('Reconnecting original user (gwilym)...');
    final originalToken = await ApiService.login('gwilym', 'azerty');
    if (originalToken != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', originalToken);
      debugPrint('Successfully reconnected original user (gwilym)');
    } else {
      debugPrint('Failed to reconnect original user');
    }
  } catch (e) {
    debugPrint('Error reconnecting original user: $e');
  }
}

Future<void> _addGwilymChallenges() async {
  // Predefined challenges for gwilym
  final gwilymChallenges = [
    {
      'firstToggle': 'un',
      'firstWord': 'pingouin',
      'preposition': 'sur',
      'secondToggle': 'une',
      'secondWord': 'banquise',
      'forbiddenWords': ['glace', 'antarctique', 'froid'],
      'id': '1'  // Add ID for tracking
    },
    {
      'firstToggle': 'une',
      'firstWord': 'licorne',
      'preposition': 'dans',
      'secondToggle': 'un',
      'secondWord': 'arc-en-ciel',
      'forbiddenWords': ['magique', 'corne', 'couleurs'],
      'id': '2'  // Add ID for tracking
    }
  ];

  try {
    debugPrint('Adding challenges for gwilym...');
    List<Map<String, dynamic>> localChallenges = [];
    
    // First, send challenges to the API
    for (var challenge in gwilymChallenges) {
      final apiChallenge = {
        "first_word": challenge['firstToggle'],
        "second_word": challenge['firstWord'],
        "third_word": challenge['preposition'],
        "fourth_word": challenge['secondToggle'],
        "fifth_word": challenge['secondWord'],
        "forbidden_words": challenge['forbiddenWords'],
      };

      final response = await ApiService.sendChallenges(widget.gameSessionId, apiChallenge);
      debugPrint('Challenge sent for gwilym: $response');
      
      // Add to local list if API call was successful
      if (response.isNotEmpty) {
        localChallenges.add(challenge);
      }
    }

    // After sending to API, update local state
    if (mounted && localChallenges.isNotEmpty) {
      setState(() {
        challenges.addAll(localChallenges);
      });
      await _saveChallenges();
      debugPrint('Added ${localChallenges.length} challenges for gwilym locally');
    }

  } catch (e) {
    debugPrint('Error adding gwilym\'s challenges: $e');
  }
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
                    try {
                      // First check if user already has challenges
                      final existingChallenges = await ApiService.getMyChallenges(widget.gameSessionId);
                      final challengesData = jsonDecode(existingChallenges.body);
                      
                      if (challengesData.isNotEmpty) {
                        // User already has challenges, navigate directly
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrawingChallengesScreen(
                                gameSessionId: widget.gameSessionId,
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      // If no existing challenges, proceed with sending new ones
                      bool allChallengesSent = true;
                      int successCount = 0;

                      for (var challenge in challenges) {
                        Map<String, dynamic> formattedChallenge = {
                          "first_word": challenge['firstToggle'],
                          "second_word": challenge['firstWord'],
                          "third_word": challenge['preposition'],
                          "fourth_word": challenge['secondToggle'],
                          "fifth_word": challenge['secondWord'],
                          "forbidden_words": challenge['forbiddenWords'],
                        };

                        final response = await ApiService.sendChallenges(
                          widget.gameSessionId, 
                          formattedChallenge
                        );
                        
                        if (response.isNotEmpty) {
                          successCount++;
                        } else {
                          allChallengesSent = false;
                          break;
                        }
                      }

                      if (allChallengesSent && successCount > 0) {
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrawingChallengesScreen(
                                gameSessionId: widget.gameSessionId,
                              ),
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to send some challenges')),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
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
