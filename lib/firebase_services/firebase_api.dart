import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as developer; // For logging

// Manages Firebase Cloud Messaging (FCM) initialization and notifications
class FirebaseApi {
  // Instance of FirebaseMessaging for interacting with FCM
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Instance of FlutterLocalNotificationsPlugin for local notifications
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Initializes FCM notifications, requests permissions, and sets up handlers
  Future<void> initNotifications() async {
    try {
      // Request notification permissions from the user
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true, // Show alerts
        badge: true, // Show badges
        sound: true, // Enable sound
        provisional: false, // Avoid provisional permissions
      );

      // Log the permission status
      developer.log(
        'Notification permission: ${settings.authorizationStatus}',
        name: 'FirebaseApi',
      );

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _localNotifications.initialize(initializationSettings);

      // Proceed only if permission is granted
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Retrieve the FCM token for this device
        final fCMToken = await _firebaseMessaging.getToken();
        developer.log('FCM Token: $fCMToken', name: 'FirebaseApi');

        // Handle token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          developer.log('FCM Token refreshed: $newToken', name: 'FirebaseApi');
          // TODO: Send new token to your server if needed
        });

        // Set up foreground message handler with local notification
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          developer.log(
            'Foreground message received: ${notification?.title ?? 'No title'}',
            name: 'FirebaseApi',
          );
          if (notification != null) {
            _showLocalNotification(notification);
          }
        });

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } else {
        developer.log(
          'Notification permission denied or provisional',
          name: 'FirebaseApi',
        );
      }
    } catch (e) {
      developer.log('Error initializing notifications: $e',
          name: 'FirebaseApi');
      if (e.toString().contains('failed-service-worker-registration')) {
        developer.log(
          'Service worker registration failed. Ensure firebase-messaging-sw.js is in web/ and correctly configured.',
          name: 'FirebaseApi',
        );
      } else if (e.toString().contains('timeout')) {
        developer.log(
          'Request timed out. Check network connectivity or Firebase configuration.',
          name: 'FirebaseApi',
        );
      }
    }
  }

  // Displays a local notification for foreground messages
  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', // Unique channel ID
      'News Notifications', // Channel name
      channelDescription: 'Notifications for news updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode, // Unique ID for each notification
      notification.title,
      notification.body,
      notificationDetails,
    );
  }
}

// Background message handler (must be top-level or static)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log(
    'Background message received: ${message.notification?.title}',
    name: 'FirebaseApi',
  );
  // Process background message (e.g., save to local storage)
}
