import 'package:currency_converter/components/simple_button.dart';
import 'package:currency_converter/components/simple_textfield.dart';
import 'package:currency_converter/user_authentication/helper/helper_function.dart'; // For displayMessageToUser
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Login page for user authentication with email and password
class LoginPage extends StatefulWidget {
  // Callback to switch to the register page
  final VoidCallback? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers for email and password input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Attempts to log in the user with Firebase Authentication
  Future<void> _login() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal during loading
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Sign in with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Close loading dialog if still mounted
      if (mounted) Navigator.pop(context);
      // StreamBuilder elsewhere (e.g., in main.dart) will handle navigation
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.code}';
      }
      if (mounted) displayMessageToUser(errorMessage, context);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      if (mounted) displayMessageToUser('Unexpected error: $e', context);
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/Currency.png",
                  height: 210,
                  width: 210, // Added for consistency
                ),
                const SizedBox(height: 25),
                const Text(
                  "Currency Converter",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                SimpleTextfield(
                  hintText: 'Email',
                  obscureText: false,
                  controller: _emailController,
                ),
                const SizedBox(height: 25),
                SimpleTextfield(
                  hintText: 'Password',
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password logic
                      displayMessageToUser(
                          'Forgot Password feature coming soon!', context);
                    },
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SimpleButton(
                  text: "Login",
                  onTap: _login,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register Here",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
