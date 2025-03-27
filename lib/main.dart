import 'package:currency_converter/AllPage.dart';
import 'package:currency_converter/CurrencyList.dart';
import 'package:currency_converter/ExchangeRateInformation.dart';
import 'package:flutter/material.dart';

import 'SupportedPage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
home:Currencylist(), 
      debugShowCheckedModeBanner: false,
      );
  }
}
