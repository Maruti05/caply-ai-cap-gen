import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  static const String _androidBannerId =
      'ca-app-pub-6224944600468190/1842913945';

  static const String _iosBannerId = 'ca-app-pub-6224944600468190/1842913945';

  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) return _androidTestBannerId;
      if (Platform.isIOS) return _iosTestBannerId;
    }
    if (Platform.isAndroid) return _androidBannerId;
    if (Platform.isIOS) return _iosBannerId;
    throw UnsupportedError('Unsupported platform');
  }

  static const AdRequest _adRequest = AdRequest();

  Future<void> initializeAds() async {
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) debugPrint('[AdMob] SDK initialized');
    } catch (e) {
      if (kDebugMode) debugPrint('[AdMob] Init error: $e');
    }
  }

  BannerAd createBannerAd({
    required AdSize size,
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: _adRequest,
      listener: listener,
    )..load();
  }

  void disposeBannerAd(BannerAd? ad) {
    try {
      ad?.dispose();
    } catch (_) {}
  }

  static Future<AdSize?> getAdaptiveSize(double width) async {
    try {
      return await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width.toInt());
    } catch (_) {
      return null;
    }
  }

  static const AdSize fallbackSize = AdSize.banner;
}
