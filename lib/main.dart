import 'package:currency_converter/RateAlerts/firebase_api.dart';
import 'package:currency_converter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:currency_converter/components/home_page.dart';
import 'package:currency_converter/Api_call/news_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load(fileName: ".env").catchError((e) {
    developer.log("Error loading .env: $e", name: 'Main');
    return null;
  });
  developer.log("Environment variables loaded: ${dotenv.env['API_KEY']}",
      name: 'Main');

  // Initialize Firebase
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    developer.log('Firebase initialized successfully', name: 'Main');
    firebaseInitialized = true;

    // Start Firebase Messaging in the background
    final firebaseApi = FirebaseApi();
    firebaseApi.initNotifications(); // Non-blocking
  } catch (e) {
    developer.log('Firebase init error: $e', name: 'Main');
  }

  runApp(MainApp(firebaseInitialized: firebaseInitialized));
}

class MainApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MainApp({super.key, this.firebaseInitialized = true});

  @override
  Widget build(BuildContext context) {
    if (!firebaseInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: Text('Failed to initialize app. Please restart.'))),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2)); // Give initialization time
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
