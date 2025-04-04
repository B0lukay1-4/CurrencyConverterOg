import 'package:flutter/material.dart';

class CurrencyPairs extends StatefulWidget {
  const CurrencyPairs({super.key});

  @override
  State<CurrencyPairs> createState() => _CurrencyPairsState();
}

class _CurrencyPairsState extends State<CurrencyPairs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back
        ),
      ),
      body: const Center(child: Text("Currency Converter Page")),
    );
  }
}
