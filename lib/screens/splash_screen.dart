// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg for SVG handling
import 'login_screen.dart'; // Import LoginScreen
import '../utils/theme.dart'; // Import the theme to use styles

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _svgOpacityAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Quick duration for the stamp effect
    );

    // Stamp-like animation with a quick zoom effect
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // Bouncing effect to simulate a stamp
      ),
    );

    // Opacity animation to fade out the SVG
    _svgOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Opacity animation to fade in the text quickly
    _textOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });

    _navigateToLogin(); // Navigate to the login screen after the animation
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3)); // Total duration of the splash screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, // Use the primary color from the theme
      body: Stack(
        children: [
          // Animation to fade out the SVG in the background
          Center(
            child: AnimatedBuilder(
              animation: _svgOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _svgOpacityAnimation.value,
                  child: SvgPicture.asset(
                    'lib/assets/images/pictionary.svg', // Path to your SVG image
                    width: MediaQuery.of(context).size.width * 0.3, // Reduce the size of the image
                    height: MediaQuery.of(context).size.height * 0.3, // Reduce the size of the image
                    fit: BoxFit.contain, // Contain the image within the box
                  ),
                );
              },
            ),
          ),
          // Animation for text with "stamp" effect
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value, // Scale animation for zoom effect
                  child: Opacity(
                    opacity: _textOpacityAnimation.value, // Opacity animation for fade-in effect
                    child: Text(
                      'Piction.AI.ry',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ), // Use text style from theme and customize
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
