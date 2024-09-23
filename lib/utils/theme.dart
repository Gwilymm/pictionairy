// lib/utils/theme.dart
import 'package:flutter/material.dart';
import 'package:floating_bubbles/floating_bubbles.dart'; // Import the floating_bubbles package
import 'colors.dart'; // Importez le fichier de couleurs

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

  // Styles de bouton communs
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonColor,
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

  // Thème général de l'application
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
      ),
      textTheme: const TextTheme(
        displayLarge: titleTextStyle, // Updated from headline1
        displayMedium: subtitleTextStyle, // Updated from headline2
        bodyLarge: bodyTextStyle, // Updated from bodyText1
        bodyMedium: bodyTextStyle, // Added for bodyText2
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

// BubbleBackground class to use anywhere in the app
class BubbleBackground {
  static Widget buildBubbles({
    int noOfBubbles = 30,
    List<Color>? colorsOfBubbles,
    double sizeFactor = 0.2,
    int opacity = 70,
    BubbleSpeed speed = BubbleSpeed.slow,
    PaintingStyle paintingStyle = PaintingStyle.fill,
    BubbleShape shape = BubbleShape.circle,
  }) {
    return FloatingBubbles.alwaysRepeating(
      noOfBubbles: noOfBubbles,
      colorsOfBubbles: colorsOfBubbles ?? [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.2),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.4),
      ],
      sizeFactor: sizeFactor,
      opacity: opacity,
      speed: speed,
      paintingStyle: paintingStyle,
      shape: shape,
    );
  }
}
