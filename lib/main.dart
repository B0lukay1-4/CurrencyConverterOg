// File: lib/main.dart
import 'package:currency_converter/firebase_options.dart';
import 'package:currency_converter/firebase_services/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:currency_converter/components/home_page.dart';
import 'package:currency_converter/Api_call/news_provider.dart';

// Entry point of the Currency Converter app
void main() async {
  // Ensure Flutter bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseInitialized = false;

  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully', name: 'Main');

    // Initialize Firebase Cloud Messaging notifications
    final firebaseApi = FirebaseApi();
    await firebaseApi.initNotifications();
    firebaseInitialized = true;
  } catch (e) {
    // Log initialization errors for debugging
    developer.log('Error during app initialization: $e', name: 'Main');
  }

  // Launch the app with initialization status
  runApp(MainApp(firebaseInitialized: firebaseInitialized));
}

// Root widget of the application, handling providers
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
            child: Text('Failed to initialize app. Please restart.'),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        // Provide NewsProvider for news data management
        ChangeNotifierProvider(create: (context) => NewsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(), // Always start with HomePage
      ),
    );
  }
}
