import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeFormScreen extends StatefulWidget {
  const ChallengeFormScreen({super.key});

  @override
  _ChallengeFormScreenState createState() => _ChallengeFormScreenState();
}

class _ChallengeFormScreenState extends State<ChallengeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstWordController = TextEditingController();
  final TextEditingController _secondWordController = TextEditingController();
  final TextEditingController _forbiddenWordController = TextEditingController();
  List<String> forbiddenWords = [];

  List<bool> isSelectedFirst = [true, false]; // UN/UNE
  List<bool> isSelectedPreposition = [true, false]; // SUR/DANS
  List<bool> isSelectedSecond = [true, false]; // UN/UNE (bottom)

  String? _validateWord(String value) {
    if (value.isEmpty) {
      return 'Ce champ ne peut pas être vide';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Seules les lettres et espaces sont autorisés';
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? challenges = prefs.getStringList('challenges');
    if (challenges != null) {
      return challenges.map((challenge) {
        return jsonDecode(challenge) as Map<String, dynamic>;
      }).toList();
    }
    return [];
  }

  Future<void> _saveChallenges(List<Map<String, dynamic>> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedChallenges = challenges.map((challenge) {
      return jsonEncode(challenge);
    }).toList();
    await prefs.setStringList('challenges', encodedChallenges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ajouter un challenge'),
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
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + kToolbarHeight, 16, 16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toggle Buttons (UN/UNE)
                    Align(
                      alignment: Alignment.center,
                      child: ToggleButtons(
                        isSelected: isSelectedFirst,
                        borderRadius: BorderRadius.circular(30),
                        selectedColor: Colors.white,
                        fillColor: Colors.purple,
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("UN")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("UNE")),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            isSelectedFirst = [index == 0, index == 1];
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First word input
                    TextFormField(
                      controller: _firstWordController,
                      decoration: InputDecoration(
                        labelText: "Votre premier mot",
                        labelStyle: const TextStyle(color: AppColors.secondaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) => _validateWord(value!),
                    ),
                    const SizedBox(height: 20),

                    // Toggle Buttons (SUR/DANS)
                    Align(
                      alignment: Alignment.center,
                      child: ToggleButtons(
                        isSelected: isSelectedPreposition,
                        borderRadius: BorderRadius.circular(30),
                        selectedColor: Colors.white,
                        fillColor: Colors.purple,
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("SUR")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("DANS")),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            isSelectedPreposition = [index == 0, index == 1];
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle Buttons (UN/UNE) bottom
                    Align(
                      alignment: Alignment.center,
                      child: ToggleButtons(
                        isSelected: isSelectedSecond,
                        borderRadius: BorderRadius.circular(30),
                        selectedColor: Colors.white,
                        fillColor: Colors.purple,
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("UN")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("UNE")),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            isSelectedSecond = [index == 0, index == 1];
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Second word input
                    TextFormField(
                      controller: _secondWordController,
                      decoration: InputDecoration(
                        labelText: "Votre deuxieme mot",
                        labelStyle: const TextStyle(color: AppColors.secondaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) => _validateWord(value!),
                    ),
                    const SizedBox(height: 20),

                    // Forbidden words input and chips
                    TextFormField(
                      controller: _forbiddenWordController,
                      decoration: InputDecoration(
                        labelText: "Ajouter un mot interdit",
                        labelStyle: const TextStyle(color: AppColors.secondaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: () {
                        if (_forbiddenWordController.text.isNotEmpty &&
                            _validateWord(_forbiddenWordController.text) == null) {
                          setState(() {
                            forbiddenWords.add(_forbiddenWordController.text);
                            _forbiddenWordController.clear();
                          });
                        }
                      },
                      style: AppTheme.elevatedButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
                      ),
                      icon: const Icon(Icons.add, color: AppColors.buttonTextColor),
                      label: const Text('Ajouter Mot Interdit', style: AppTheme.buttonTextStyle),
                    ),
                    const SizedBox(height: 20),

                    // Display forbidden words as chips
                    Wrap(
                      spacing: 8.0,
                      children: forbiddenWords
                          .map(
                            (word) => Chip(
                          label: Text(word),
                          onDeleted: () {
                            setState(() {
                              forbiddenWords.remove(word);
                            });
                          },
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final challenge = {
                            'firstToggle': isSelectedFirst[0] ? "UN" : "UNE",
                            'firstWord': _firstWordController.text,
                            'preposition': isSelectedPreposition[0] ? "SUR" : "DANS",
                            'secondToggle': isSelectedSecond[0] ? "UN" : "UNE",
                            'secondWord': _secondWordController.text,
                            'forbiddenWords': forbiddenWords,
                          };

                          // Load existing challenges
                          List<Map<String, dynamic>> existingChallenges = await _loadChallenges();

                          // Add the new challenge to the list
                          existingChallenges.add(challenge);

                          // Save the updated challenge list
                          await _saveChallenges(existingChallenges);

                          // Return to previous screen
                          Navigator.pop(context, challenge);
                        }
                      },
                      style: AppTheme.elevatedButtonStyle,
                      icon: const Icon(Icons.check, color: AppColors.buttonTextColor),
                      label: const Text('Ajouter', style: AppTheme.buttonTextStyle),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
