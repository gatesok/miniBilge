import 'package:flutter/foundation.dart';

/// Platform and build-mode aware AdMob ad unit configuration.
///
/// Production Android IDs are intentionally supplied through dart-defines:
/// `ADMOB_ANDROID_INTERSTITIAL_ID` and `ADMOB_ANDROID_REWARDED_ID`.
/// When an ID is absent ads are disabled safely for that format.
abstract final class AdConfig {
  static const _iosInterstitialProduction =
      String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID',
          defaultValue: 'ca-app-pub-6415056821465724/7095740008');
  static const _iosRewardedProduction =
      String.fromEnvironment('ADMOB_IOS_REWARDED_ID',
          defaultValue: 'ca-app-pub-6415056821465724/6109961398');
  static const _androidInterstitialProduction =
      String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID');
  static const _androidRewardedProduction =
      String.fromEnvironment('ADMOB_ANDROID_REWARDED_ID');

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ca-app-pub-3940256099942544/4411468910',
        TargetPlatform.android => 'ca-app-pub-3940256099942544/1033173712',
        _ => '',
      };
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => _iosInterstitialProduction,
      TargetPlatform.android => _androidInterstitialProduction,
      _ => '',
    };
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ca-app-pub-3940256099942544/1712485313',
        TargetPlatform.android => 'ca-app-pub-3940256099942544/5224354917',
        _ => '',
      };
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => _iosRewardedProduction,
      TargetPlatform.android => _androidRewardedProduction,
      _ => '',
    };
  }

  static bool get hasInterstitialAdUnit => interstitialAdUnitId.isNotEmpty;
  static bool get hasRewardedAdUnit => rewardedAdUnitId.isNotEmpty;
}
