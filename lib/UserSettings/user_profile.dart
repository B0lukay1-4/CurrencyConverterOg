import 'package:currency_converter/UserSettings/user_notification_settings.dart'
    as custom;
import 'package:currency_converter/UserSettings/user_feedback.dart';
import 'package:currency_converter/user_authentication/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Logs out the current user and navigates to the login screen
  Future<void> _logout(BuildContext context) async {
    try {
      // Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      // Navigate to LoginOrRegister screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  // Navigates to the login page
  void _login(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsItem(
              context,
              title: 'User Support and Help Center',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User Support page coming soon!')),
                );
              },
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              title: 'Manage Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => custom.UserNotificationSettings()),
                );
              },
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              title: 'User Feedback',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              title: 'User Preferences',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User Preferences page coming soon!')),
                );
              },
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              title: isAuthenticated ? 'Logout' : 'Login',
              onTap: () => isAuthenticated ? _logout(context) : _login(context),
              textColor: isAuthenticated ? Colors.red : Colors.blue,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required String title, required VoidCallback onTap, Color? textColor}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: textColor ?? Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right, size: 30),
      onTap: onTap,
    );
  }
}
