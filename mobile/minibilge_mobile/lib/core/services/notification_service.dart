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
    void Function(String title, String body)? onForegroundMessage,
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

    // Token refresh listener — set up FIRST so it's always active
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed: $newToken');
      await onTokenReceived(newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title} — ${message.notification?.body}');
      final title = message.notification?.title ?? '';
      final body  = message.notification?.body  ?? '';
      if (title.isNotEmpty && onForegroundMessage != null) {
        onForegroundMessage(title, body);
      }
    });

    // Notification tapped while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapped (background): ${message.data}');
    });

    // Notification tapped while app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App opened from terminated via notification: ${initialMessage.data}');
    }

    // Try to get initial token in background (non-blocking)
    _fetchAndRegisterToken(onTokenReceived);
  }

  /// Tries to get FCM token (non-blocking). firebase_messaging 15.x handles APNS internally.
  static Future<void> _fetchAndRegisterToken(
      Future<void> Function(String token) onTokenReceived) async {
    // Retry up to 10 times with increasing delay — APNS registration can take time on first launch
    for (int attempt = 0; attempt < 10; attempt++) {
      try {
        final token = await _messaging.getToken().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('[FCM] getToken timed out (attempt ${attempt + 1}).');
            return null;
          },
        );
        if (token != null && token.isNotEmpty) {
          debugPrint('[FCM] Token obtained: ${token.substring(0, 20)}...');
          await onTokenReceived(token);
          return; // success
        }
      } catch (e) {
        debugPrint('[FCM] getToken error (attempt ${attempt + 1}): $e');
      }
      // Exponential-ish backoff: 3s, 5s, 8s, 10s, 15s...
      final delay = Duration(seconds: [3, 5, 8, 10, 15, 20, 30, 30, 30, 30][attempt]);
      debugPrint('[FCM] Retrying in ${delay.inSeconds}s (attempt ${attempt + 1}/10)...');
      await Future.delayed(delay);
    }
    debugPrint('[FCM] Could not obtain FCM token after 10 attempts.');
  }


  /// Returns the current FCM token, or null if unavailable.
  /// firebase_messaging 15.x handles APNS token internally on iOS.
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[FCM] getToken timed out.');
          return null;
        },
      );
    } catch (e) {
      debugPrint('[FCM] getToken error (ignored): $e');
      return null;
    }
  }
}
