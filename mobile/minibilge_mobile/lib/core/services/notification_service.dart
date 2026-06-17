import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler — must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized when this runs.
  // No UI operations allowed here.
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Call once at app startup (after Firebase.initializeApp).
  static Future<void> initialize({
    required Future<void> Function(String token) onTokenReceived,
  }) async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request iOS permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Notification permission denied.');
      return;
    }

    // Get and register token
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('[FCM] Token: $token');
      await onTokenReceived(token);
    }

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed: $newToken');
      await onTokenReceived(newToken);
    });

    // Foreground messages (show in-app banner)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          '[FCM] Foreground message: ${message.notification?.title} — ${message.notification?.body}');
      // TODO: show in-app notification UI if needed
    });

    // Notification tapped while app in background (opened)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapped (background): ${message.data}');
      // TODO: deep link navigation if needed
    });

    // Notification tapped while app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          '[FCM] App opened from terminated via notification: ${initialMessage.data}');
      // TODO: deep link navigation if needed
    }
  }

  /// Returns the current FCM token, or null if unavailable.
  static Future<String?> getToken() => _messaging.getToken();
}
