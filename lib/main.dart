import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Add this line
import 'utils/theme.dart'; // Importez le fichier de thème
import 'screens/home_screen.dart'; // Import the HomeScreen
import 'screens/login_screen.dart'; // Import the LoginScreen
import 'controllers/login_controller.dart'; // Import the LoginController
import 'controllers/challenge_form_controller.dart'; // Import the ChallengeFormController
import 'package:provider/provider.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Add this line
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Test AdUnitId Android
      : 'ca-app-pub-3940256099942544/2934735716'; // Test AdUnitId iOS

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate(),
      );

      if (size == null) {
        debugPrint('Failed to get banner ad size.');
        return;
      }

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        request: const AdRequest(),
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            setState(() {
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            debugPrint('BannerAd failed to load: $err');
            ad.dispose();
          },
        ),
      )..load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChallengeFormController()),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'Pictionairy',
        theme: ThemeData.light(), // Ajoutez votre thème personnalisé ici
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/home': (_) => const HomeScreen(),
          '/login': (_) => const LoginScreen(),
        },
        builder: (context, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: _isLoaded
                ? Container(
              color: Colors.transparent,
              child: AdWidget(ad: _bannerAd!),
              height: _bannerAd!.size.height.toDouble(),
            )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LoginController _loginController = LoginController();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isLoggedIn = await _loginController.autoLogin();
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Indicateur de chargement
      ),
    );
  }
}
