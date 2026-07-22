import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AnalyticsClient {
  Future<void> setCollectionEnabled(bool enabled);
  Future<void> logEvent(String name, Map<String, Object> parameters);
  Future<void> setUserProperty(String name, String? value);
  Future<void> setUserId(String? id);
}

final class FirebaseAnalyticsClient implements AnalyticsClient {
  FirebaseAnalyticsClient(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setCollectionEnabled(bool enabled) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);
}

final class NoOpAnalyticsClient implements AnalyticsClient {
  const NoOpAnalyticsClient();

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}

/// Privacy-safe analytics gateway for all MiniBilge features.
///
/// Feature code must use this service instead of calling Firebase directly.
/// Free-form user content, names, email addresses and nicknames must never be
/// included in event parameters.
abstract final class AnalyticsService {
  static AnalyticsClient _client = const NoOpAnalyticsClient();
  static String _appVersion = 'unknown';

  static const _sensitiveKeyFragments = {
    'email',
    'nickname',
    'child_name',
    'user_name',
    'full_name',
    'prompt',
    'question_text',
    'answer_text',
    'spoken_text',
    'free_text',
    'transcript',
    'response_body',
    'message',
  };

  static Future<void> initialize() async {
    try {
      _client = FirebaseAnalyticsClient(FirebaseAnalytics.instance);
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      const explicitlyEnabled = bool.fromEnvironment(
        'FIREBASE_OBSERVABILITY_ENABLED',
      );
      const enabled = kReleaseMode || explicitlyEnabled;
      await _client.setCollectionEnabled(enabled);
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
        if (_isSensitiveKey(entry.key)) continue;
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

      await _client.logEvent(name, sanitized);
    } catch (error) {
      debugPrint('[Analytics] Event $name failed: $error');
    }
  }

  static Future<void> setGradeGroup(String? gradeGroup) async {
    try {
      await _client.setUserProperty('grade_group', gradeGroup ?? 'unknown');
    } catch (error) {
      debugPrint('[Analytics] User property failed: $error');
    }
  }

  static Future<void> clearUserState() async {
    try {
      await _client.setUserId(null);
      await _client.setUserProperty('grade_group', null);
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

  static String resultBucket(int score) {
    if (score < 40) return 'low';
    if (score < 80) return 'medium';
    return 'high';
  }

  static String errorType(Object error) {
    final type = error.runtimeType.toString().toLowerCase();
    if (type.contains('dio')) return 'network';
    if (type.contains('timeout')) return 'timeout';
    if (type.contains('format') || type.contains('json')) return 'invalid_data';
    return 'unknown';
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    if (normalized == 'name' || normalized.endsWith('_name')) return true;
    return _sensitiveKeyFragments.any(normalized.contains);
  }

  @visibleForTesting
  static void useClientForTesting(
    AnalyticsClient client, {
    String appVersion = 'test',
  }) {
    _client = client;
    _appVersion = appVersion;
  }

  @visibleForTesting
  static void resetClientForTesting() {
    _client = const NoOpAnalyticsClient();
    _appVersion = 'unknown';
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

/// Bir ekran/provider yaşam döngüsü içinde aynı mantıksal event'in yalnızca
/// bir kez gönderilmesini sağlar. Yeni aktivitede [reset] çağrılabilir.
final class AnalyticsEventGuard {
  final Set<String> _sentKeys = {};

  Future<void> logOnce(
    String dedupeKey,
    String eventName, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (!_sentKeys.add(dedupeKey)) return;
    await AnalyticsService.logEvent(eventName, parameters: parameters);
  }

  void reset([String? dedupeKey]) {
    if (dedupeKey == null) {
      _sentKeys.clear();
    } else {
      _sentKeys.remove(dedupeKey);
    }
  }
}
