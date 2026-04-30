import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

/// Provider for managing AdMob state and lifecycle
/// Handles loading, showing, and disposing of banner ads
class AdMobProvider extends ChangeNotifier {
  final AdMobService _adMobService = AdMobService();

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  String? _errorMessage;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isAdLoaded => _isAdLoaded;
  bool get isAdLoading => _isAdLoading;
  String? get errorMessage => _errorMessage;
  bool get shouldShowBanner => _isAdLoaded && _adMobService.shouldShowAds();

  /// Initialize AdMob service
  Future<void> initialize() async {
    try {
      await _adMobService.initializeAds();
    } catch (e) {
      _errorMessage = 'Failed to initialize AdMob: $e';
      if (kDebugMode) {
        print('[AdMobProvider] $_errorMessage');
      }
    }
  }

  /// Load a new banner ad
  Future<void> loadBannerAd() async {
    if (_isAdLoading || _isAdLoaded) {
      return; // Already loading or loaded
    }

    if (kDebugMode) {
      print('[AdMobProvider] Starting to load banner ad...');
    }

    _isAdLoading = true;
    notifyListeners();

    try {
      // Dispose old ad if exists
      if (_bannerAd != null) {
        await _adMobService.disposeBannerAd(_bannerAd);
      }

      // Load new banner ad
      _bannerAd = _adMobService.loadBannerAd(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: _onAdFailedToLoad,
      );
    } catch (e) {
      _errorMessage = 'Error loading banner ad: $e';
      _isAdLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('[AdMobProvider] $_errorMessage');
      }
    }
  }

  /// Callback when ad loads successfully
  void _onAdLoaded(Ad ad) {
    if (kDebugMode) {
      print('[AdMobProvider] Banner ad loaded successfully');
    }
    _isAdLoaded = true;
    _isAdLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Callback when ad fails to load
  void _onAdFailedToLoad(Ad ad, LoadAdError error) {
    if (kDebugMode) {
      print('[AdMobProvider] Banner ad failed to load: ${error.message}');
      print('[AdMobProvider] Error code: ${error.code}, domain: ${error.domain}');
    }
    _isAdLoaded = false;
    _isAdLoading = false;
    _errorMessage = error.message;
    notifyListeners();
  }

  /// Reload banner ad
  Future<void> reloadBannerAd() async {
    _isAdLoaded = false;
    _isAdLoading = false;
    await loadBannerAd();
  }

  /// Dispose resources
  @override
  Future<void> dispose() async {
    try {
      await _adMobService.disposeBannerAd(_bannerAd);
      _bannerAd = null;
      _isAdLoaded = false;
      _isAdLoading = false;
    } catch (e) {
      if (kDebugMode) {
        print('[AdMobProvider] Error disposing ads: $e');
      }
    }
    super.dispose();
  }
}
