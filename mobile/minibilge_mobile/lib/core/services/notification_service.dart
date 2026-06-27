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

    // Token refresh listener — set up FIRST so it's always active
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed: $newToken');
      await onTokenReceived(newToken);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title} — ${message.notification?.body}');
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

  /// Tries to get FCM token with APNs retry (up to 5 attempts, non-blocking).
  static Future<void> _fetchAndRegisterToken(
      Future<void> Function(String token) onTokenReceived) async {
    try {
      // On iOS, APNs token must be available first.
      // Retry a few times since it can take a moment on first launch / real device.
      String? apnsToken;
      for (int attempt = 0; attempt < 5; attempt++) {
        apnsToken = await _messaging.getAPNSToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        if (apnsToken != null) break;
        debugPrint('[FCM] APNs token not ready, retrying (${attempt + 1}/5)...');
        await Future.delayed(const Duration(seconds: 3));
      }

      if (apnsToken == null) {
        debugPrint('[FCM] APNs token unavailable after retries (simulator or no entitlement). Skipping FCM token.');
        return;
      }

      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[FCM] getToken timed out.');
          return null;
        },
      );
      if (token != null) {
        debugPrint('[FCM] Token obtained: ${token.substring(0, 20)}...');
        await onTokenReceived(token);
      }
    } catch (e) {
      debugPrint('[FCM] Token error (ignored): $e');
    }
  }


  /// Returns the current FCM token, or null if unavailable.
  /// On iOS, waits for APNS token before calling getToken (avoids apns-token-not-set crash).
  static Future<String?> getToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
        if (apnsToken == null) {
          debugPrint('[FCM] getToken: APNS token not ready, skipping.');
          return null;
        }
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[FCM] getToken error (ignored): $e');
      return null;
    }
  }
}
