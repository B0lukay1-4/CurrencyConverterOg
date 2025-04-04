import 'package:currency_converter/RateAlerts/currency_pairs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  // Helper method to check if user is logged in
  bool _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = _isUserLoggedIn();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Currency Converter - always accessible
            _buildClickableRow(
              context,
              icon: Icons.currency_exchange_sharp,
              text: "Currency Converter",
              page: const Placeholder(),
              isEnabled: true, // Always enabled
            ),
            const SizedBox(height: 30),
            // Set Currency Rates - requires login
            _buildClickableRow(
              context,
              icon: Icons.compare_arrows_sharp,
              text: "Set Currency Rates",
              page: isLoggedIn ? CurrencyPairs() : null,
              isEnabled: isLoggedIn,
            ),
            const SizedBox(height: 30),
            // Historical Rates - requires login
            _buildClickableRow(
              context,
              icon: Icons.trending_up_sharp,
              text: "Historical Rates and Trends",
              page: isLoggedIn ? const Placeholder() : null,
              isEnabled: isLoggedIn,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableRow(BuildContext context,
      {required IconData icon,
      required String text,
      required Widget? page,
      required bool isEnabled}) {
    return GestureDetector(
      onTap: isEnabled && page != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          : () {
              if (!isEnabled) {
                // Show dialog or snackbar when not logged in
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please log in to access this feature'),
                  ),
                );
              }
            },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? Colors.grey : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isEnabled ? Colors.white : Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isEnabled ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
