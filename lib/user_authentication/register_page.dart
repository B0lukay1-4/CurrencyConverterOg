import 'package:currency_converter/components/simple_button.dart';
import 'package:currency_converter/components/simple_textfield.dart';
import 'package:currency_converter/user_authentication/helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Registration page for creating a new user account
class RegisterPage extends StatefulWidget {
  // Callback to switch to the login page
  final VoidCallback? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers for user input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  // State for password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Registers a new user with Firebase Authentication
  Future<void> _registerUser() async {
    // Basic form validation
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final confirmPassword = _confirmPwController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        confirmPassword.isEmpty) {
      displayMessageToUser('Please fill in all fields.', context);
      return;
    }

    // Username length check
    if (username.length < 3) {
      displayMessageToUser('Username must be at least 3 characters.', context);
      return;
    }

    // Password match validation
    if (password != confirmPassword) {
      displayMessageToUser("Passwords don't match", context);
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal during loading
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name with username
      await userCredential.user!.updateDisplayName(username);

      // Close loading dialog if still mounted
      if (mounted) Navigator.pop(context);
      // StreamBuilder elsewhere (e.g., in main.dart) will handle navigation
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading dialog
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPwController.dispose();
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
                  width: 210,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Currency Converter",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                SimpleTextfield(
                  hintText: 'Username',
                  obscureText: false,
                  controller: _usernameController,
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
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  // Add suffix icon for visibility toggle
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 25),
                SimpleTextfield(
                  hintText: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  controller: _confirmPwController,
                  // Add suffix icon for visibility toggle
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password logic (post-registration)
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
                  text: "Register",
                  onTap: _registerUser,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login Here",
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
