import 'package:flutter/material.dart';

// A reusable text field widget with customizable hint text and obscurity
class SimpleTextfield extends StatelessWidget {
  // Placeholder text displayed when the field is empty
  final String hintText;

  // Whether the text should be obscured (e.g., for passwords)
  final bool obscureText;

  // Controller to manage the text input
  final TextEditingController controller;

  final Widget? suffixIcon;

  const SimpleTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Links the input to the provided controller
      obscureText: obscureText, // Hides text if true (e.g., for passwords)
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        hintText: hintText, // Displays hint text
        hintStyle: TextStyle(
          color: Colors.grey.shade400, // Subtle hint color
        ),
        filled: true, // Enables background fill
        fillColor: Colors.grey.shade100, // Light background for contrast
        suffixIcon: suffixIcon,
      ),
    );
  }
}
