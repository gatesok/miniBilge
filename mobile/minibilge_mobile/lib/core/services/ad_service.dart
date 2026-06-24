import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  /// iOS rewarded ad unit ID.
  /// Debug builds use Google's official test ID automatically.
  static const String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1712485313' // Google test rewarded (iOS)
      : 'ca-app-pub-6415056821465724/6109961398'; // MiniBilge iOS rewarded

  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;

  /// Call once at app startup after [MobileAds.instance.initialize()].
  static void preload() {
    _loadAd();
  }

  static void _loadAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _rewardedAd = null;
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
  }) {
    if (!_isAdLoaded || _rewardedAd == null) {
      onComplete?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdLoaded = false;
        _rewardedAd = null;
        _loadAd(); // preload for next time
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAdLoaded = false;
        _rewardedAd = null;
        _loadAd();
        onComplete?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
  }

  static bool get isAdLoaded => _isAdLoaded;
}

/// Manages interstitial ads (existing feature — math quiz).
class AdService {
  AdService._();

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/4411468910' // Google test interstitial (iOS)
      : 'ca-app-pub-6415056821465724/7095740008'; // MiniBilge iOS interstitial

  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

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
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onComplete}) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          loadInterstitialAd();
          onComplete?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
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
