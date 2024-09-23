// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Importez SplashScreen
import 'utils/theme.dart'; // Importez le fichier de thème

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piction.AI.ry',
      theme: AppTheme.theme, // Utilisez le thème défini dans theme.dart
      home: const SplashScreen(), // Utilisez le SplashScreen comme point d'entrée
      debugShowCheckedModeBanner: false, // Supprimer le bandeau de debug
    );
  }
}
