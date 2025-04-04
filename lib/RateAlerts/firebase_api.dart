import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    try {
      // Request permission (non-blocking)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        carPlay: false,
        criticalAlert: false,
      );
      developer.log('Notification permission: ${settings.authorizationStatus}',
          name: 'FirebaseApi');

      // Initialize local notifications (minimal setup)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _localNotifications.initialize(initializationSettings);

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Fetch FCM token in the background
        _firebaseMessaging.getToken().then((fCMToken) {
          developer.log('FCM Token: $fCMToken', name: 'FirebaseApi');
        }).catchError((e) {
          developer.log('FCM Token error: $e', name: 'FirebaseApi');
        });

        // Subscribe to user topic if authenticated
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _firebaseMessaging.subscribeToTopic(user.uid).then((_) {
            developer.log('Subscribed to topic: ${user.uid}',
                name: 'FirebaseApi');
          });
        }

        // Token refresh listener
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          developer.log('FCM Token refreshed: $newToken', name: 'FirebaseApi');
        });

        // Foreground message handler
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          if (notification != null) {
            showLocalNotification(notification);
          }
        });

        // Background handler already set in main.dart
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      developer.log('Error initializing notifications: $e',
          name: 'FirebaseApi');
    }
  }

  Future<void> showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'News Notifications',
      channelDescription: 'Notifications for news updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Background message received: ${message.notification?.title}',
      name: 'FirebaseApi');
}
