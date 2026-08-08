import 'package:flutter/foundation.dart';

/// AppLovin MAX ad unit configuration.
///
/// AdMob hesabımız geçersiz trafik nedeniyle askıya alındığı için yedek/alternatif
/// reklam ağı olarak entegre ediliyor. Gerçek SDK key/Ad Unit ID'ler AppLovin
/// hesabı onaylanıp panelden alındıktan sonra dart-define ile sağlanacak; ID'ler
/// boşken reklamlar güvenli şekilde devre dışı kalır (AdConfig'teki desenle aynı).
///
/// Kullanım: --dart-define=APPLOVIN_SDK_KEY=... --dart-define=APPLOVIN_ANDROID_INTERSTITIAL_ID=...
abstract final class AppLovinConfig {
  static const sdkKey = String.fromEnvironment('APPLOVIN_SDK_KEY');

  static const _iosInterstitial =
      String.fromEnvironment('APPLOVIN_IOS_INTERSTITIAL_ID');
  static const _iosRewarded =
      String.fromEnvironment('APPLOVIN_IOS_REWARDED_ID');
  static const _androidInterstitial =
      String.fromEnvironment('APPLOVIN_ANDROID_INTERSTITIAL_ID');
  static const _androidRewarded =
      String.fromEnvironment('APPLOVIN_ANDROID_REWARDED_ID');

  static String get interstitialAdUnitId => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => _iosInterstitial,
    TargetPlatform.android => _androidInterstitial,
    _ => '',
  };

  static String get rewardedAdUnitId => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => _iosRewarded,
    TargetPlatform.android => _androidRewarded,
    _ => '',
  };

  static bool get hasSdkKey => sdkKey.isNotEmpty;
  static bool get hasInterstitialAdUnit => interstitialAdUnitId.isNotEmpty;
  static bool get hasRewardedAdUnit => rewardedAdUnitId.isNotEmpty;
}
