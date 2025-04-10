import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/logger.dart';

/// Service for handling Firebase Cloud Messaging notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Singleton pattern
  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Initialize the notification service
  Future<void> initialize() async {
    // Request permission for notifications
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Log permission status
    Logger.info('User granted permission: ${settings.authorizationStatus}');

    // Get the token
    final token = await _messaging.getToken();
    Logger.info('FCM Token: $token');

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('Got a message whilst in the foreground!');
      Logger.info('Message data: ${message.data}');

      if (message.notification != null) {
        Logger.info('Message also contained a notification: ${message.notification}');
      }

      // Handle the message (e.g., show a local notification)
    });

    // Handle message when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle the message (e.g., navigate to a specific screen)
      }
    });

    // Handle message when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Logger.info('Message clicked!');
      // Handle the message (e.g., navigate to a specific screen)
    });
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Get the FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
