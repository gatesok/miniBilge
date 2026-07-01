import 'dart:math';
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
    void Function(RemoteMessage message)? onNotificationTap,
    void Function(RemoteMessage message)? onForegroundData,
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
      onForegroundData?.call(message);
    });

    // Notification tapped while app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapped (background): ${message.data}');
      onNotificationTap?.call(message);
    });

    // Notification tapped while app was terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App opened from terminated via notification: ${initialMessage.data}');
      // Delay to allow the widget tree and router to be ready
      Future.delayed(const Duration(milliseconds: 500), () {
        onNotificationTap?.call(initialMessage);
      });
    }

    // Try to get initial token in background (non-blocking)
    _fetchAndRegisterToken(onTokenReceived);
  }

  /// Tries to get FCM token (non-blocking). firebase_messaging 15.x handles APNS internally.
  /// NOTE: Returns null on iOS Simulators — push notifications require a real device.
  static Future<void> _fetchAndRegisterToken(
      Future<void> Function(String token) onTokenReceived) async {
    // iOS: explicitly wait for APNS token BEFORE calling getToken().
    // Calling getToken() before iOS registers with APNS causes "apns-token-not-set" error.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apnsToken;
      for (int i = 0; i < 20; i++) {
        try {
          apnsToken = await _messaging.getAPNSToken();
        } catch (e) {
          debugPrint('[FCM] getAPNSToken error: $e');
        }
        if (apnsToken != null) {
          debugPrint('[FCM] APNS token ready: ${apnsToken.substring(0, min(20, apnsToken.length))}...');
          break;
        }
        debugPrint('[FCM] Waiting for APNS token... (attempt ${i + 1}/20)');
        await Future.delayed(const Duration(seconds: 3));
      }
      if (apnsToken == null) {
        debugPrint('[FCM] APNS token unavailable after 60s. '
            'Push notifications disabled. Ensure this is a real device with '
            'push notification entitlement and APNs key in Firebase Console.');
        return;
      }
    }

    // Retry FCM getToken up to 5 times with increasing delay
    const delays = [3, 5, 8, 10, 15];
    for (int attempt = 0; attempt < delays.length; attempt++) {
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
        debugPrint('[FCM] getToken returned null (attempt ${attempt + 1}). '
            'Check: real device required, push notification entitlement, '
            'APNs key in Firebase Console.');
      } catch (e) {
        debugPrint('[FCM] getToken error (attempt ${attempt + 1}): $e');
      }
      final delay = Duration(seconds: delays[attempt]);
      debugPrint('[FCM] Retrying in ${delay.inSeconds}s...');
      await Future.delayed(delay);
    }
    debugPrint('[FCM] Could not obtain FCM token after ${delays.length} attempts. '
        'Push notifications will not work. '
        'Ensure you are running on a REAL device (not a simulator).');
  }


  /// Returns the current FCM token, or null if unavailable.
  /// Non-blocking: returns null immediately if APNS is not ready yet.
  /// Background registration via _fetchAndRegisterToken handles the retry loop.
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken().timeout(
        const Duration(seconds: 5),
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
