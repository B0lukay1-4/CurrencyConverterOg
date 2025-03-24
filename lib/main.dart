import 'package:currency_converter/Api_call/news_provider.dart'; // Import your provider
import 'package:currency_converter/CurrencyNews%20and%20Market%20Trends/news_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => NewsProvider()), // Add your provider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const NewsPage(),
      ),
    );
  }
}
