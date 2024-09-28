import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/services/api_service.dart'; // Import your API service

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  _JoinGameScreenState createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rejoindre une partie'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
          Positioned.fill(
            child: BubbleBackground.buildBubbles(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Placez le QR code dans la zone de scan',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 1,
                    child: QRCodeDartScanView(
                      onCapture: (data) {
                        _handleQRCodeScan(context, data);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        // Additional functionality if needed
                      },
                      style: AppTheme.elevatedButtonStyle,
                      child: const Text(
                        'Scan QR Code',
                        style: AppTheme.buttonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCodeScan(BuildContext context, dynamic data) async {
    String? sessionId;

    if (data is String) {
      sessionId = data;
    } else if (data is Result) {
      sessionId = data.text;
    }

    if (sessionId != null) {
      // After extracting sessionId, attempt to join the session
      await _joinGameSession(context, sessionId);
    } else {
      _showErrorDialog(context, 'Invalid QR Code');
    }
  }

  Future<void> _joinGameSession(BuildContext context, String sessionId) async {
    // Show dialog to choose team color
    final color = await _showColorChoiceDialog(context);
    if (color == null) return; // User canceled the color selection

    final response = await ApiService.joinGameSession(sessionId, color);

    _showSuccessDialog(context, 'You have joined the session!');
    }

  Future<String?> _showColorChoiceDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a Team'),
          content: const Text('Select a team to join:'),
          actions: <Widget>[
            TextButton(
              child: const Text('Blue'),
              onPressed: () {
                Navigator.of(context).pop('blue');
              },
            ),
            TextButton(
              child: const Text('Red'),
              onPressed: () {
                Navigator.of(context).pop('red');
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
