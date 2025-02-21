import 'package:flutter/material.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/services/api_service.dart';
import 'dart:convert';

class DrawingChallengesScreen extends StatefulWidget {
  final String gameSessionId;

  const DrawingChallengesScreen({
    Key? key,
    required this.gameSessionId,
  }) : super(key: key);

  @override
  _DrawingChallengesScreenState createState() => _DrawingChallengesScreenState();
} 

class _DrawingChallengesScreenState extends State<DrawingChallengesScreen> {
  List<Map<String, dynamic>> myChallenges = [];
  bool _isLoading = true;

  final Map<int, TextEditingController> _promptControllers = {};
  final Map<int, String> _generatedImages = {}; // Stocker les images générées

  @override
  void initState() {
    super.initState();
    _loadMyChallenges();
  }

  @override
  void dispose() {
    // Nettoyer tous les controllers
    for (var controller in _promptControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMyChallenges() async {
    try {
      final response = await ApiService.getMyChallenges(widget.gameSessionId);
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final sessionData = jsonDecode(response.body);
        debugPrint('Session data: $sessionData');

        if (sessionData is List) {
          // On suppose que `sessionData` est déjà une liste de challenges
          setState(() {
            myChallenges = List<Map<String, dynamic>>.from(sessionData);
            _isLoading = false;
          });
        } else if (sessionData is Map<String, dynamic> && sessionData.containsKey('challenges')) {
          // Cas où `challenges` est dans un objet
          final allChallenges = List<Map<String, dynamic>>.from(sessionData['challenges'] ?? []);
          final currentPlayerId = sessionData['player_id'];

          // Filtrer les challenges pour ce joueur
          final playerChallenges = allChallenges.where((challenge) {
            return challenge.containsKey('challenged_id') && challenge['challenged_id'] == currentPlayerId;
          }).toList();

          debugPrint('Found ${playerChallenges.length} challenges for player $currentPlayerId');

          setState(() {
            myChallenges = playerChallenges;
            _isLoading = false;
          });
        } else {
          debugPrint('Unexpected data format: $sessionData');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Error loading challenges: HTTP ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

 Future<void> _generateImage(int challengeId) async {
  try {
    final controller = _promptControllers[challengeId];

    if (controller == null || controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prompt')),
      );
      return;
    }

    // Afficher un indicateur de chargement
    setState(() {
      _generatedImages[challengeId] = ""; // Placeholder pour affichage
    });

    debugPrint("Envoi du prompt à l'API : ${controller.text}");

    // Appel API
    final response = await ApiService.generateImageWithPrompt(
      widget.gameSessionId,
      challengeId.toString(),
      controller.text,
    );

    if (response != null && response.isNotEmpty) {
      debugPrint("Image générée : $response");

      setState(() {
        _generatedImages[challengeId] = response;
      });

      _showImageDialog(response, controller.text);
    } else {
      debugPrint("Erreur : L'API a retourné 200 mais sans image_path !");
      setState(() {
        _generatedImages.remove(challengeId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Aucune image retournée')),
      );
    }
  } catch (e) {
    debugPrint('Erreur lors de la génération de l\'image: $e');

    setState(() {
      _generatedImages.remove(challengeId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la génération: $e')),
    );
  }
}





  void _showImageDialog(String imageUrl, String promptText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl),
            const SizedBox(height: 16),
            Text(promptText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Drawing Challenges'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : myChallenges.isEmpty
              ? const Center(child: Text("Aucun challenge disponible."))
              : ListView.builder(
                  itemCount: myChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = myChallenges[index];
                    final challengeId = challenge['id'] is int
                        ? challenge['id']
                        : int.tryParse(challenge['id'].toString()) ?? 0;

                    _promptControllers[challengeId] ??= TextEditingController();

                    final sentence =
                        '${challenge['first_word']} ${challenge['second_word']} ${challenge['third_word']} ${challenge['fourth_word']} ${challenge['fifth_word']}'
                            .trim();
                    
                    // Vérifier si `forbidden_words` est déjà une liste ou une chaîne JSON
                    final forbiddenWords = challenge['forbidden_words'];
                    List<dynamic> forbiddenList;
                    if (forbiddenWords is String) {
                      try {
                        forbiddenList = jsonDecode(forbiddenWords);
                      } catch (_) {
                        forbiddenList = [];
                      }
                    } else if (forbiddenWords is List) {
                      forbiddenList = forbiddenWords;
                    } else {
                      forbiddenList = [];
                    }

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Challenge ${index + 1}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Draw: $sentence',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Forbidden words:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.red,
                                  ),
                            ),
                            Wrap(
                              spacing: 8,
                              children: forbiddenList
                                  .map((word) => Chip(
                                        label: Text(word.toString()),
                                        backgroundColor: Colors.red[100],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _promptControllers[challengeId],
                              decoration: const InputDecoration(
                                labelText: 'Enter your prompt',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _generateImage(challengeId),
                              child: const Text('Generate Image'),
                            ),
                           if (_generatedImages.containsKey(challengeId)) ...[
                              const SizedBox(height: 16),
                              if (_generatedImages[challengeId] == null || _generatedImages[challengeId]!.isEmpty)
                                const Center(child: CircularProgressIndicator()) // Afficher un spinner pendant la génération
                              else
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _generatedImages[challengeId]!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Prompt: ${_promptControllers[challengeId]?.text}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],

                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
