import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class AdMobProvider extends ChangeNotifier {
  final AdMobService _adMobService = AdMobService();

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  String? _errorMessage;

  bool _isDisposed = false;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isAdLoaded => _isAdLoaded;
  bool get isAdLoading => _isAdLoading;
  String? get errorMessage => _errorMessage;
  bool get shouldShowBanner => _isAdLoaded && _adMobService.shouldShowAds();

  /// Initialize AdMob
  Future<void> initialize() async {
    try {
      await _adMobService.initializeAds();
    } catch (e) {
      _errorMessage = 'AdMob init failed';
      _safeNotify();
      if (kDebugMode) {
        print('[AdMobProvider] Init error: $e');
      }
    }
  }

  /// Load Banner
  void loadBannerAd() {
    if (_isAdLoading || _isAdLoaded || _isDisposed) return;

    if (kDebugMode) {
      print('[AdMobProvider] Loading banner...');
    }

    _isAdLoading = true;
    _errorMessage = null;
    _safeNotify();

    // Dispose old ad
    _adMobService.disposeBannerAd(_bannerAd);
    _bannerAd = null;

    _bannerAd = _adMobService.loadBannerAd(
      onAdLoaded: _onAdLoaded,
      onAdFailedToLoad: _onAdFailedToLoad,
    );
  }

  /// Success callback
  void _onAdLoaded(Ad ad) {
    if (_isDisposed) return;

    if (kDebugMode) {
      print('[AdMobProvider] Banner loaded');
    }

    _isAdLoaded = true;
    _isAdLoading = false;
    _errorMessage = null;
    _safeNotify();
  }

  /// Failure callback
  void _onAdFailedToLoad(Ad ad, LoadAdError error) {
    if (_isDisposed) return;

    if (kDebugMode) {
      print(
          '[AdMobProvider] Failed: ${error.code} | ${error.message}');
    }

    _isAdLoaded = false;
    _isAdLoading = false;

    /// Show generic error to user
    _errorMessage = 'Ad unavailable. Please try again later.';
    _safeNotify();
  }

  /// Manual reload (used for retry button)
  void reloadBannerAd() {
    if (_isDisposed) return;

    _isAdLoaded = false;
    _isAdLoading = false;
    loadBannerAd();
  }

  /// Safe notify (prevents crash after dispose)
  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Dispose (must NOT be async)
  @override
  void dispose() {
    _isDisposed = true;

    _adMobService.disposeBannerAd(_bannerAd);
    _bannerAd = null;

    super.dispose();
  }
}