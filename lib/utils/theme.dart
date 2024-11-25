// lib/utils/theme.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import 'colors.dart';

class AppTheme {
  // Styles de texte communs
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.primaryColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    color: AppColors.buttonTextColor,
  );

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonColor,
    // text color
    foregroundColor: AppColors.buttonTextColor,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );


  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    side: const BorderSide(color: AppColors.primaryColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
      ),
      textTheme: const TextTheme(
        displayLarge: titleTextStyle,
        displayMedium: subtitleTextStyle,
        bodyLarge: bodyTextStyle,
        bodyMedium: bodyTextStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryColor,
        ),
      ),
    );
  }
}

// BubbleBackground class
class BubbleBackground {
  static Widget buildBubbles({
    int noOfBubbles = 30,
    List<Color>? colorsOfBubbles,
    double sizeFactor = 0.2,
    int opacity = 70,
    BubbleSpeed speed = BubbleSpeed.slow,
    PaintingStyle paintingStyle = PaintingStyle.fill,
    BubbleShape shape = BubbleShape.circle,
    bool isInteractive = false, // Permet d'activer/désactiver l'interactivité
    VoidCallback? onBubbleTapped, // Callback pour capturer les clics
  }) {
    return Stack(
      children: [
        // Fond statique ou coloré (optionnel)
        Positioned.fill(
          child: Container(
            color: Colors.transparent, // Peut être remplacé par un dégradé
          ),
        ),
        // Bulles animées avec FloatingBubbles
        Positioned.fill(
          child: FloatingBubbles.alwaysRepeating(
            noOfBubbles: noOfBubbles,
            colorsOfBubbles: colorsOfBubbles ?? [
              Colors.green.withAlpha(30),
              Colors.red,
              Colors.blue.withOpacity(0.3),
              Colors.yellow.withOpacity(0.3),
            ],
            sizeFactor: sizeFactor,
            opacity: opacity,
            paintingStyle: paintingStyle,
            shape: shape,
            speed: speed,
          ),
        ),
        // Couche interactive (ajoutée si isInteractive est true)
        if (isInteractive)
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                if (onBubbleTapped != null) {
                  onBubbleTapped();
                }
                debugPrint('Bubble tapped at position: ${details}');
              },
              child: Container(
                color: Colors.transparent, // Couvre l'écran pour capturer les clics
              ),
            ),
          ),
      ],
    );
  }
}
