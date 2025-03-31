import 'package:currency_converter/CurrencyList.dart';
import 'package:currency_converter/HistroyRateInformation.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
home:Histroyrateinformation(searchQuery: '',),
      debugShowCheckedModeBanner: false,
      );
  }
}
