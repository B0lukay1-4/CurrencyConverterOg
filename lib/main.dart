// import 'package:currency_converter/SplashScreen/SplashScreen.dart';
// import 'package:currency_converter/firebase_options.dart';
// import 'package:currency_converter/firebase_services/firebase_api.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'dart:developer' as developer;
// import 'package:provider/provider.dart';
// import 'package:currency_converter/components/home_page.dart';
// import 'package:currency_converter/Api_call/news_provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   bool firebaseInitialized = false;

//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     final firebaseApi = FirebaseApi();
//     await firebaseApi.initNotifications();

//     firebaseInitialized = true;
//     developer.log('Firebase initialized successfully', name: 'Main');
//   } catch (e) {
//     developer.log('Error during app initialization: $e', name: 'Main');
//   }

//   runApp(MainApp(firebaseInitialized: firebaseInitialized));
// }

// class MainApp extends StatelessWidget {
//   final bool firebaseInitialized;

//   const MainApp({super.key, required this.firebaseInitialized});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => NewsProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: firebaseInitialized ? const HomePage() : const Splashscreen(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:currency_converter/SplashScreen/SplashScreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      // Your normal app flow
      home: const Splashscreen(),
    );
  }
}
