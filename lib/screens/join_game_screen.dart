// lib/screens/join_game_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart'; // Import QR code scanner package
import 'package:pictionairy/utils/theme.dart'; // Import AppTheme
import 'package:pictionairy/utils/colors.dart'; // Import AppColors

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({Key? key}) : super(key: key);

  @override
  _JoinGameScreenState createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to extend behind the AppBar
      appBar: AppBar(
        title: const Text('Rejoindre une partie'),
        backgroundColor: Colors.transparent, // Make AppBar transparent to show background
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Grape soda background with gradient
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

          // Animated Bubble Background using BubbleBackground class
          Positioned.fill(
            child: BubbleBackground.buildBubbles(), // Reusable bubble background
          ),

          // Main content
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
                        _showQRCodeInfo(context, data); // Show QR code info when scanned
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200, // Set a fixed width for the button
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your onPressed code here if needed
                      },
                      style: AppTheme.elevatedButtonStyle, // Use button style from theme
                      child: const Text(
                        'Scan QR Code',
                        style: AppTheme.buttonTextStyle, // Use button text style from theme
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

  /// Displays a popup dialog with the QR code information.
  ///
  /// \param context The build context.
  /// \param data The data captured from the QR code.
  void _showQRCodeInfo(BuildContext context, dynamic data) {
    String displayData;
    if (data is String) {
      displayData = data;
    } else if (data is Result) {
      displayData = data.text;
    } else {
      displayData = data.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Information'),
          content: Text('Data: $displayData'),
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
