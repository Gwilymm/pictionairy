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
  bool isLoading = true;
  final Map<int, TextEditingController> _promptControllers = {};
  final Map<int, String> _generatedImages = {}; // Add this line to store images

  @override
  void initState() {
    super.initState();
    _loadMyChallenges();
  }

  @override
  void dispose() {
    // Clean up all controllers
    _promptControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadMyChallenges() async {
    try {
      final response = await ApiService.getMyChallenges(widget.gameSessionId);
      setState(() {
        myChallenges = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading challenges: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _generateImage(int challengeId) async {
    try {
      final controller = _promptControllers[challengeId];
      if (controller == null || controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a prompt')),
        );
        return;
      }

      final response = await ApiService.generateImageWithPrompt(
        widget.gameSessionId,
        challengeId.toString(),
        controller.text,
      );

      if (response != null) {
        setState(() {
          _generatedImages[challengeId] = response; // Store the generated image URL
        });
        _showImageDialog(response, controller.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating image: $e')),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: myChallenges.length,
              itemBuilder: (context, index) {
                final challenge = myChallenges[index];
                final challengeId = challenge['id'] as int;
                
                // Create a controller for this challenge if it doesn't exist
                _promptControllers[challengeId] ??= TextEditingController();

                final sentence = '${challenge['first_word']} ${challenge['second_word']} ${challenge['third_word']} ${challenge['fourth_word']} ${challenge['fifth_word']}'
                    .trim();
                final forbiddenWords = jsonDecode(challenge['forbidden_words'] as String) as List<dynamic>;

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
                          
                          children: forbiddenWords
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
