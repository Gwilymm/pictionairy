import 'package:flutter/material.dart';
import 'package:pictionairy/controllers/challenge_form_controller.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:provider/provider.dart';

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

  List<bool> isSelectedFirst = [true, false]; // UN/UNE
  List<bool> isSelectedPreposition = [true, false]; // SUR/DANS
  List<bool> isSelectedSecond = [true, false]; // UN/UNE (bottom)

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ChallengeFormController>(context);

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
          // Votre code pour le fond et les bulles
          // ...

          Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + kToolbarHeight, 16, 16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildToggleButtons(
                      label: 'UN/UNE',
                      isSelected: isSelectedFirst,
                      options: const ['UN', 'UNE'],
                      onPressed: (index) => setState(() => isSelectedFirst = [index == 0, index == 1]),
                    ),
                    const SizedBox(height: 20),
                    _buildTextInput(
                      controller: _firstWordController,
                      label: "Votre premier mot",
                      validator: (value) => controller.validateWord(value!),
                    ),
                    const SizedBox(height: 20),
                    _buildToggleButtons(
                      label: 'SUR/DANS',
                      isSelected: isSelectedPreposition,
                      options: const ['SUR', 'DANS'],
                      onPressed: (index) => setState(() => isSelectedPreposition = [index == 0, index == 1]),
                    ),
                    const SizedBox(height: 20),
                    _buildToggleButtons(
                      label: 'UN/UNE',
                      isSelected: isSelectedSecond,
                      options: const ['UN', 'UNE'],
                      onPressed: (index) => setState(() => isSelectedSecond = [index == 0, index == 1]),
                    ),
                    const SizedBox(height: 20),
                    _buildTextInput(
                      controller: _secondWordController,
                      label: "Votre deuxième mot",
                      validator: (value) => controller.validateWord(value!),
                    ),
                    const SizedBox(height: 20),
                    _buildTextInput(
                      controller: _forbiddenWordController,
                      label: "Ajouter un mot interdit",
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_forbiddenWordController.text.isNotEmpty &&
                            controller.validateWord(_forbiddenWordController.text) == null) {
                          controller.addForbiddenWord(_forbiddenWordController.text);
                          _forbiddenWordController.clear();
                        }
                      },
                      icon: const Icon(Icons.add, color: AppColors.buttonTextColor),
                      label: const Text('Ajouter Mot Interdit', style: AppTheme.buttonTextStyle),
                      style: AppTheme.elevatedButtonStyle,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8.0,
                      children: controller.forbiddenWords
                          .map(
                            (word) => Chip(
                          label: Text(word),
                          onDeleted: () => controller.removeForbiddenWord(word),
                        ),
                      )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final challenge = {
                            'firstToggle': isSelectedFirst[0] ? "UN" : "UNE",
                            'firstWord': _firstWordController.text,
                            'preposition': isSelectedPreposition[0] ? "SUR" : "DANS",
                            'secondToggle': isSelectedSecond[0] ? "UN" : "UNE",
                            'secondWord': _secondWordController.text,
                            'forbiddenWords': controller.forbiddenWords,
                          };

                          List<Map<String, dynamic>> existingChallenges =
                          await controller.loadChallenges();
                          existingChallenges.add(challenge);
                          await controller.saveChallenges(existingChallenges);

                          Navigator.pop(context, challenge);
                        }
                      },
                      icon: const Icon(Icons.check, color: AppColors.buttonTextColor),
                      label: const Text('Ajouter', style: AppTheme.buttonTextStyle),
                      style: AppTheme.elevatedButtonStyle,
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

  Widget _buildToggleButtons({
    required String label,
    required List<bool> isSelected,
    required List<String> options,
    required void Function(int) onPressed,
  }) {
    return Align(
      alignment: Alignment.center,
      child: ToggleButtons(
        isSelected: isSelected,
        borderRadius: BorderRadius.circular(30),
        selectedColor: Colors.white,
        fillColor: Colors.purple,
        children: options
            .map((option) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(option),
        ))
            .toList(),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.secondaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}
