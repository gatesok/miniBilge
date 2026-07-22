import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Privacy-safe analytics gateway for all MiniBilge features.
///
/// Feature code must use this service instead of calling Firebase directly.
/// Free-form user content, names, email addresses and nicknames must never be
/// included in event parameters.
abstract final class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static String _appVersion = 'unknown';

  static Future<void> initialize() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      const explicitlyEnabled = bool.fromEnvironment(
        'FIREBASE_OBSERVABILITY_ENABLED',
      );
      const enabled = kReleaseMode || explicitlyEnabled;
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (error) {
      debugPrint('[Analytics] Initialization failed: $error');
    }
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    try {
      final sanitized = <String, Object>{
        'platform': _platformName,
        'app_version': _appVersion,
      };

      for (final entry in parameters.entries) {
        final value = entry.value;
        if (value is String && value.isNotEmpty) {
          sanitized[entry.key] = value.length > 100
              ? value.substring(0, 100)
              : value;
        } else if (value is bool) {
          sanitized[entry.key] = value ? 1 : 0;
        } else if (value is num) {
          sanitized[entry.key] = value;
        }
      }

      await _analytics.logEvent(name: name, parameters: sanitized);
    } catch (error) {
      debugPrint('[Analytics] Event $name failed: $error');
    }
  }

  static Future<void> setGradeGroup(String? gradeGroup) async {
    try {
      await _analytics.setUserProperty(
        name: 'grade_group',
        value: gradeGroup ?? 'unknown',
      );
    } catch (error) {
      debugPrint('[Analytics] User property failed: $error');
    }
  }

  static Future<void> clearUserState() async {
    try {
      await _analytics.setUserId(id: null);
      await _analytics.setUserProperty(name: 'grade_group', value: null);
    } catch (error) {
      debugPrint('[Analytics] User state reset failed: $error');
    }
  }

  static String gradeGroupForAge(int age) {
    if (age <= 5) return 'preschool';
    if (age <= 7) return 'grade_1_2';
    if (age <= 10) return 'grade_3_4';
    if (age <= 17) return 'teen';
    return 'adult';
  }

  static String get _platformName => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };
}

abstract final class AnalyticsEvents {
  static const appOpened = 'app_opened';
  static const sessionStarted = 'session_started';
  static const loginCompleted = 'login_completed';
  static const registerCompleted = 'register_completed';
  static const childProfileCreated = 'child_profile_created';
  static const childProfileSelected = 'child_profile_selected';
  static const contentOpened = 'content_opened';
  static const quizStarted = 'quiz_started';
  static const quizCompleted = 'quiz_completed';
  static const quizAbandoned = 'quiz_abandoned';
  static const englishActivityStarted = 'english_activity_started';
  static const englishActivityCompleted = 'english_activity_completed';
  static const entertainmentStarted = 'entertainment_started';
  static const entertainmentCompleted = 'entertainment_completed';
  static const wordleStarted = 'wordle_started';
  static const wordleCompleted = 'wordle_completed';
  static const attemptLimitReached = 'attempt_limit_reached';
  static const adLoadSucceeded = 'ad_load_succeeded';
  static const adLoadFailed = 'ad_load_failed';
  static const adImpression = 'ad_impression';
  static const adDismissed = 'ad_dismissed';
  static const adShowFailed = 'ad_show_failed';
  static const rewardEarned = 'reward_earned';
  static const premiumIntent = 'premium_intent';
  static const premiumFeatureTapped = 'premium_feature_tapped';
  static const apiError = 'api_error';
  static const contentLoadFailed = 'content_load_failed';
}
