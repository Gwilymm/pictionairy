import 'package:flutter/material.dart';
import 'package:pictionairy/controllers/challenge_form_controller.dart';
import 'package:provider/provider.dart';

class ChallengeCard extends StatelessWidget {
  final String gameSessionId;
  final String challengeId;
  // ...existing code...

  @override
  Widget build(BuildContext context) {
    final challengeFormController = Provider.of<ChallengeFormController>(context);

    return Card(
      // ...existing code...
      child: Column(
        // ...existing code...
        children: [
          // ...existing code...
          ElevatedButton(
            onPressed: () async {
              String? imageUrl = await challengeFormController.generateImage(gameSessionId, challengeId);
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
          // ...existing code...
        ],
      ),
    );
  }
}
