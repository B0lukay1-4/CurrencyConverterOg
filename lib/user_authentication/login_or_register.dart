import 'package:currency_converter/user_authentication/login_page.dart';
import 'package:currency_converter/user_authentication/register_page.dart';
import 'package:flutter/material.dart';

// Toggles between login and registration pages based on user interaction
class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Tracks whether to show the login page (true) or register page (false)
  bool _showLoginPage = true;

  // Toggles between login and register pages
  void _togglePages() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLoginPage
        ? LoginPage(onTap: _togglePages)
        : RegisterPage(onTap: _togglePages);
  }
}
