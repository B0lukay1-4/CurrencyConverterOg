import 'package:flutter/material.dart';

// A reusable button widget with customizable color, text, and tap action
class SimpleButton extends StatelessWidget {
  // Background color of the button
  final Color color;

  // Text displayed on the button
  final String text;

  // Callback function executed when the button is tapped (nullable)
  final VoidCallback? onTap;

  const SimpleButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Triggers the provided callback when tapped
      child: Container(
        decoration: BoxDecoration(
          color: color, // Applies the custom background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        padding: const EdgeInsets.all(25), // Consistent padding
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white, // White text for contrast
            ),
          ),
        ),
      ),
    );
  }
}
