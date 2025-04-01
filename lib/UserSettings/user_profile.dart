// File: lib/user_authentication/settings_page.dart
import 'package:flutter/material.dart';

// Settings page for authenticated users
class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 2, // Slight shadow for depth
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context); // Return to previous page (e.g., HomePage)
        //   },
        // ),
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
                // TODO: Navigate to User Support and Help Center page
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
                // TODO: Navigate to Manage Notifications page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Manage Notifications page coming soon!')),
                );
              },
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              title: 'User Feedback',
              onTap: () {
                // TODO: Navigate to User Feedback page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User Feedback page coming soon!')),
                );
              },
            ),
            const Divider(),
            _buildSettingsItem(
              context,
              title: 'User Preferences',
              onTap: () {
                // TODO: Navigate to User Preferences page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User Preferences page coming soon!')),
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  // Builds a single settings item with title and chevron
  Widget _buildSettingsItem(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      trailing: const Icon(Icons.chevron_right, size: 30),
      onTap: onTap,
    );
  }
}
