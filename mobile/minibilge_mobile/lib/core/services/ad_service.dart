import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages interstitial ads for the app.
///
/// The app targets children (ages 4–10), so COPPA and child-directed
/// treatment flags are enabled — ads are non-personalised.
///
/// **Production setup:**
/// 1. Go to https://admob.google.com and create an app + interstitial ad unit.
/// 2. Replace [_interstitialAdUnitId] with your real iOS Ad Unit ID.
/// 3. Replace the GADApplicationIdentifier in ios/Runner/Info.plist with your
///    real AdMob App ID.
class AdService {
  AdService._();

  /// iOS interstitial ad unit ID.
  /// In debug builds the official Google test ID is used automatically.
  /// In release builds replace the string below with your real Ad Unit ID.
  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/4411468910' // Google test interstitial (iOS)
      : 'YOUR_IOS_INTERSTITIAL_AD_UNIT_ID'; // TODO: replace before publishing

  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  /// Call once at app startup (after [WidgetsFlutterBinding.ensureInitialized]).
  static Future<void> initialize() async {
    // Child-directed treatment — required for COPPA compliance.
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    await MobileAds.instance.initialize();
    loadInterstitialAd();
  }

  /// Loads an interstitial ad in the background so it is ready to show.
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

  /// Shows the preloaded interstitial ad.
  ///
  /// [onComplete] is called:
  /// - after the ad is dismissed by the user, or
  /// - immediately when no ad is available (so navigation is never blocked).
  static void showInterstitialAd({VoidCallback? onComplete}) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          loadInterstitialAd(); // preload for next session
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
      // Ad not ready — proceed without interruption.
      onComplete?.call();
    }
  }
}
