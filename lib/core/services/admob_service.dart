import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  static const String _androidBannerId =
      'ca-app-pub-6224944600468190/1842913945';

  // ⚠️ Replace with real iOS ID before release
  static const String _iosBannerId =
      'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) return _androidBannerId;
    if (Platform.isIOS) return _iosBannerId;
    throw UnsupportedError('Unsupported platform');
  }

  /// Initialize Ads
  Future<void> initializeAds() async {
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        print('[AdMob] Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AdMob] Init error: $e');
      }
    }
  }

  /// Load Banner with Retry + Debug
  BannerAd loadBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    int retryCount = 0,
  }) {
    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('[AdMob] Banner loaded');
          }
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          if (kDebugMode) {
            print(
                '[AdMob] Failed: ${error.code} | ${error.message} | retry=$retryCount');
          }

          onAdFailedToLoad(ad, error);

          /// 🔁 Retry logic (IMPORTANT)
          if (retryCount < 3) {
            Future.delayed(const Duration(seconds: 3), () {
              loadBannerAd(
                onAdLoaded: onAdLoaded,
                onAdFailedToLoad: onAdFailedToLoad,
                retryCount: retryCount + 1,
              );
            });
          }
        },
        onAdImpression: (ad) {
          if (kDebugMode) {
            print('[AdMob] Impression recorded');
          }
        },
      ),
    );

    bannerAd.load();
    return bannerAd;
  }

  /// Dispose banner safely
  void disposeBannerAd(BannerAd? ad) {
    try {
      ad?.dispose();
      if (kDebugMode) {
        print('[AdMob] Banner disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AdMob] Dispose error: $e');
      }
    }
  }

  /// Check if ads should show
  bool shouldShowAds() {
    return true;
  }

  /// Adaptive banner (better than fixed size)
  static Future<AdSize?> getAdaptiveSize(double width) async {
    return await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width.toInt(),
    );
  }
}