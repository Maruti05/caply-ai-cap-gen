import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// Production-ready AdMob service for managing ad lifecycle
/// Handles initialization, loading, and disposal of ads
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();

  factory AdMobService() {
    return _instance;
  }

  AdMobService._internal();

  static const String _androidBannerId = 'ca-app-pub-6224944600468190/1842913945';
  static const String _iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  /// Get the appropriate banner ad unit ID based on platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerId;
    } else if (Platform.isIOS) {
      return _iosBannerId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Initialize Google Mobile Ads SDK
  /// Call this once in your main() function
  Future<void> initializeAds() async {
    if (kDebugMode) {
      print('[AdMob] Initializing Google Mobile Ads SDK...');
    }
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        print('[AdMob] Google Mobile Ads SDK initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AdMob] Error initializing Google Mobile Ads: $e');
      }
    }
  }

  /// Load a banner ad
  /// Returns a BannerAd instance ready to be displayed
  BannerAd loadBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner, // Standard 320x50 banner
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) {
          if (kDebugMode) {
            print('[AdMob] BannerAd opened.');
          }
        },
        onAdClosed: (Ad ad) {
          if (kDebugMode) {
            print('[AdMob] BannerAd closed.');
          }
        },
        onAdImpression: (Ad ad) {
          if (kDebugMode) {
            print('[AdMob] BannerAd impression recorded.');
          }
        },
      ),
    );

    bannerAd.load();
    return bannerAd;
  }

  /// Dispose of a banner ad
  Future<void> disposeBannerAd(BannerAd? ad) async {
    if (ad != null) {
      try {
        await ad.dispose();
        if (kDebugMode) {
          print('[AdMob] BannerAd disposed successfully.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[AdMob] Error disposing BannerAd: $e');
        }
      }
    }
  }

  /// Check if ads should be shown based on user preferences
  /// This can be extended to support rewarded users or premium subscriptions
  bool shouldShowAds() {
    // TODO: Add logic for premium users or user preferences
    return true;
  }

  /// Get adaptive banner size based on screen width
  /// Adapts to different device sizes for better ad performance
  static AdSize getAdaptiveBannerAdSize(double width) {
    final adSize = AdSize(
      width: width.toInt(),
      height: 50,
    );
    return adSize;
  }
}
