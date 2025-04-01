import 'package:currency_converter/firebase_options.dart';
import 'package:currency_converter/firebase_services/firebase_api.dart';
import 'package:currency_converter/user_authentication/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:currency_converter/components/home_page.dart';
import 'package:currency_converter/Api_call/news_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully', name: 'Main');

    // Initialize notifications
    final firebaseApi = FirebaseApi();
    await firebaseApi.initNotifications();
  } catch (e) {
    developer.log('Error during app initialization: $e', name: 'Main');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NewsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                // User is authenticated, show HomePage
                return const HomePage();
              } else {
                // User is not authenticated, show LoginOrRegister
                return LoginOrRegister();
              }
            }),
      ),
    );
  }
}
