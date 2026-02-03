import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permissions for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carryForward: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentSound: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageClick(message);
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);

    debugPrint('Notification service initialized');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Handling a foreground message: ${message.messageId}');

    await _showLocalNotification(
      title: message.notification?.title ?? 'Notes App',
      body: message.notification?.body ?? '',
    );
  }

  Future<void> _handleMessageClick(RemoteMessage message) {
    debugPrint('Message clicked: ${message.messageId}');
    // Handle navigation or other logic when notification is tapped
    return Future.value();
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'notes_app_channel',
      'Notes Notifications',
      channelDescription: 'Notifications for notes app events',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }

  // Show notification for new note synced
  Future<void> showNoteSyncedNotification() async {
    await _showLocalNotification(
      title: '📝 New note synced',
      body: 'Your note has been synced successfully',
    );
  }

  // Show notification for notes backed up
  Future<void> showBackupSuccessNotification() async {
    await _showLocalNotification(
      title: '☁️ Notes backed up successfully',
      body: 'All your notes are safe and synced',
    );
  }

  // Show notification for sync error
  Future<void> showSyncErrorNotification() async {
    await _showLocalNotification(
      title: '⚠️ Sync failed',
      body: 'Failed to sync notes. Please try again.',
    );
  }

  // Get FCM token (useful for sending targeted notifications from backend)
  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic for notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}

// Background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}
