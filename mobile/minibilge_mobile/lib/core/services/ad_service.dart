import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import 'analytics_service.dart';

abstract final class AdPlacements {
  static const globalPreload = 'global_preload';
  static const mathQuizResult = 'math_quiz_result';
  static const podcastQuizResult = 'podcast_quiz_result';
  static const flashcardResult = 'flashcard_result';
  static const adaptiveQuizResult = 'adaptive_quiz_result';
  static const entertainmentResult = 'entertainment_result';
  static const wordleLevelResult = 'wordle_level_result';
  static const extraAttempt = 'extra_attempt';
  static const entertainmentExtraAttempt = 'entertainment_extra_attempt';
  static const adaptiveQuizExtraAttempt = 'adaptive_quiz_extra_attempt';
  static const writingExtraAttempt = 'writing_extra_attempt';
  static const pronunciationExtraAttempt = 'pronunciation_extra_attempt';
  static const rolePlayExtraAttempt = 'role_play_extra_attempt';
  static const vocabExtraAttempt = 'vocab_extra_attempt';
  static const wordleJoker = 'wordle_joker';
}

/// Manages rewarded ads for writing practice extra attempts.
///
/// COPPA / child-directed treatment flags are enabled — ads are
/// non-personalised and rated G.
///
/// **Production setup:**
/// 1. Go to https://admob.google.com and create a Rewarded ad unit.
/// 2. Replace [_rewardedAdUnitId] with your real iOS Ad Unit ID.
/// 3. Replace GADApplicationIdentifier in ios/Runner/Info.plist with your
///    real AdMob App ID.
class RewardedAdService {
  RewardedAdService._();

  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;
  static String _activePlacement = AdPlacements.globalPreload;

  /// Call once at app startup after [MobileAds.instance.initialize()].
  static void preload() {
    _loadAd();
  }

  static void _loadAd() {
    if (!AdConfig.hasRewardedAdUnit) {
      debugPrint('[AdMob] Rewarded ads disabled: ad unit ID is missing.');
      _isAdLoaded = false;
      _rewardedAd = null;
      return;
    }

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adLoadSucceeded,
              parameters: const {
                'format': 'rewarded',
                'placement': AdPlacements.globalPreload,
              },
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _rewardedAd = null;
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adLoadFailed,
              parameters: {
                'format': 'rewarded',
                'placement': AdPlacements.globalPreload,
                'error_code': error.code,
              },
            ),
          );
        },
      ),
    );
  }

  /// Shows the rewarded ad.
  ///
  /// [onRewarded] is called when the user earns the reward (watched fully).
  /// [onComplete] is called when the ad closes (rewarded or dismissed).
  /// If no ad is available, [onComplete] is called immediately without reward.
  static void showRewardedAd({
    required void Function() onRewarded,
    VoidCallback? onComplete,
    String placement = AdPlacements.extraAttempt,
  }) {
    if (!_isAdLoaded || _rewardedAd == null) {
      onComplete?.call();
      return;
    }

    _activePlacement = placement;
    var rewardDelivered = false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdImpression: (ad) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.adImpression,
            parameters: {'format': 'rewarded', 'placement': _activePlacement},
          ),
        );
      },
      onAdDismissedFullScreenContent: (ad) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.adDismissed,
            parameters: {'format': 'rewarded', 'placement': _activePlacement},
          ),
        );
        ad.dispose();
        _isAdLoaded = false;
        _rewardedAd = null;
        _loadAd(); // preload for next time
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.adShowFailed,
            parameters: {
              'format': 'rewarded',
              'placement': _activePlacement,
              'error_code': error.code,
            },
          ),
        );
        ad.dispose();
        _isAdLoaded = false;
        _rewardedAd = null;
        _loadAd();
        onComplete?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (rewardDelivered) return;
        rewardDelivered = true;
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.rewardEarned,
            parameters: {
              'placement': _activePlacement,
              'reward_type': reward.type,
            },
          ),
        );
        onRewarded();
      },
    );
  }

  static bool get isAdLoaded => _isAdLoaded;
}

/// Manages interstitial ads (existing feature — math quiz).
class AdService {
  AdService._();

  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;
  static String _activePlacement = AdPlacements.globalPreload;

  static Future<void> initialize() async {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    await MobileAds.instance.initialize();
    loadInterstitialAd();
    RewardedAdService.preload();
  }

  static void loadInterstitialAd() {
    if (!AdConfig.hasInterstitialAdUnit) {
      debugPrint('[AdMob] Interstitial ads disabled: ad unit ID is missing.');
      _isAdLoaded = false;
      _interstitialAd = null;
      return;
    }

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adLoadSucceeded,
              parameters: const {
                'format': 'interstitial',
                'placement': AdPlacements.globalPreload,
              },
            ),
          );
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _interstitialAd = null;
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adLoadFailed,
              parameters: {
                'format': 'interstitial',
                'placement': AdPlacements.globalPreload,
                'error_code': error.code,
              },
            ),
          );
        },
      ),
    );
  }

  static void showInterstitialAd({
    VoidCallback? onComplete,
    String placement = AdPlacements.globalPreload,
  }) {
    if (_isAdLoaded && _interstitialAd != null) {
      _activePlacement = placement;
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdImpression: (ad) {
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adImpression,
              parameters: {
                'format': 'interstitial',
                'placement': _activePlacement,
              },
            ),
          );
        },
        onAdDismissedFullScreenContent: (ad) {
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adDismissed,
              parameters: {
                'format': 'interstitial',
                'placement': _activePlacement,
              },
            ),
          );
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          loadInterstitialAd();
          onComplete?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          unawaited(
            AnalyticsService.logEvent(
              AnalyticsEvents.adShowFailed,
              parameters: {
                'format': 'interstitial',
                'placement': _activePlacement,
                'error_code': error.code,
              },
            ),
          );
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          onComplete?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      onComplete?.call();
    }
  }
}
