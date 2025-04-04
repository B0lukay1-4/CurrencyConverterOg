import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotificationSettings extends StatefulWidget {
  const UserNotificationSettings({super.key});

  @override
  _UserNotificationSettingsState createState() =>
      _UserNotificationSettingsState();
}

class _UserNotificationSettingsState extends State<UserNotificationSettings> {
  bool _rateAlertsEnabled = true;
  bool _appUpdatesEnabled = true;
  double? _rateLimit;
  final TextEditingController _rateLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rateAlertsEnabled = prefs.getBool('rateAlertsEnabled') ?? true;
      _appUpdatesEnabled = prefs.getBool('appUpdatesEnabled') ?? true;
      _rateLimit = prefs.getDouble('rateLimit');
      if (_rateLimit != null) {
        _rateLimitController.text = _rateLimit!.toString();
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rateAlertsEnabled', _rateAlertsEnabled);
    await prefs.setBool('appUpdatesEnabled', _appUpdatesEnabled);
    if (_rateLimitController.text.isNotEmpty) {
      _rateLimit = double.tryParse(_rateLimitController.text);
      if (_rateLimit != null) {
        await prefs.setDouble('rateLimit', _rateLimit!);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preferences saved')),
    );
  }

  @override
  void dispose() {
    _rateLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Preferences',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Customize which notifications you want to receive.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 20),
            _buildNotificationItem(
              title: 'Rate Alerts',
              subtitle:
                  'Get notified when exchange rates hit your set thresholds.',
              value: _rateAlertsEnabled,
              onChanged: (bool newValue) =>
                  setState(() => _rateAlertsEnabled = newValue),
            ),
            if (_rateAlertsEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: _rateLimitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Set Rate Limit (e.g., 1.2)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            Divider(),
            _buildNotificationItem(
              title: 'App Updates',
              subtitle:
                  'Receive important updates and announcements about the app.',
              value: _appUpdatesEnabled,
              onChanged: (bool newValue) =>
                  setState(() => _appUpdatesEnabled = newValue),
            ),
            Divider(),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                child: Text('Save Preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: TextStyle(fontSize: 14)),
      ),
      trailing:
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
    );
  }
}
