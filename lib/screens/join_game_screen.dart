import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:pictionairy/utils/theme.dart';
import 'package:pictionairy/utils/colors.dart';
import 'package:pictionairy/controllers/join_game_controller.dart';
import 'package:pictionairy/services/api_service.dart';
import 'dart:convert';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  _JoinGameScreenState createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final JoinGameController _controller = JoinGameController();
  bool _isScanning = true; // Flag to control scanning state
  bool _isProcessing = false; // Flag for showing loading indicator

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
          // Arrière-plan avec un dégradé
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
          // Fond animé avec des bulles
          Positioned.fill(
            child: BubbleBackground.buildBubbles(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Titre
                  Text(
                    'Placez le QR code dans la zone de scan',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Zone de scan
                  AspectRatio(
                    aspectRatio: 1,
                    child: _isScanning
                        ? QRCodeDartScanView(
                      onCapture: (data) {
                        _handleQRCodeScan(context, data);
                      },
                    )
                        : _isProcessing
                        ? const SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        color: Colors.white, // Couleur contrastante
                        strokeWidth: 4.0, // Épaisseur
                      ),
                    )
                        : const SizedBox.shrink(), // Placeholder
                  ),
                  const SizedBox(height: 20),
                  // Bouton Scan QR Code
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _restartScan,
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
    // Stop scanning and show loading indicator
    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    String? sessionId = data is String
        ? data
        : data is Result
        ? data.text
        : null;

    if (sessionId != null) {
      try {
        // Retrieve the current connected user and game session details
        String connectedUser = await _getConnectedUser();
        Map<String, dynamic> gameSession =
        await _getGameSessionDetails(sessionId);

        await _controller.joinGame(
            context, sessionId, connectedUser, gameSession);
      } catch (e) {
        // Show error dialog and wait for it to be dismissed before restarting scan
        await _controller.showErrorDialog(context, e.toString());
        _restartScan();
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    } else {
      await _controller.showErrorDialog(context, 'Code QR invalide');
      _restartScan(); // Restart scanning if the QR code is invalid
    }
  }

  Future<String> _getConnectedUser() async {
    // Logic to retrieve the current connected user
    return 'connectedUser'; // Replace with actual logic
  }

  Future<Map<String, dynamic>> _getGameSessionDetails(String sessionId) async {
    // Logic to retrieve game session details from API
    final response = await ApiService.getGameSessionDetails(sessionId);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve game session details');
    }
  }

  void _restartScan() {
    // Delay the restart to prevent immediate rescanning
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
    });
  }
}
