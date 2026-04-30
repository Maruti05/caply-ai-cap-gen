import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/admob_service.dart';

class AdBannerWidget extends StatefulWidget {
  final double height;
  final EdgeInsets padding;
  final bool showDivider;

  const AdBannerWidget({
    super.key,
    this.height = 60,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.showDivider = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _hasInternet = false;
  String? _errorMessage;
  final AdMobService _adMobService = AdMobService();
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoadAd();
    _startConnectivityListener();
  }

  /// Check internet connectivity before loading ad
  Future<void> _checkConnectivityAndLoadAd() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _hasInternet = _checkHasInternet(connectivityResult);

    if (kDebugMode) {
      print('[AdBannerWidget] Internet connectivity: $_hasInternet');
    }

    if (_hasInternet) {
      _loadBannerAd();
    } else {
      setState(() {
        _errorMessage = 'No internet connection';
        _isAdLoading = false;
      });
    }
  }

  /// Check if there's actual internet access (not just connected to WiFi)
  bool _checkHasInternet(List<ConnectivityResult> results) {
    // Check if there's any connectivity (wifi, mobile, ethernet)
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    // Cancel connectivity subscription if any
    super.dispose();
  }

  /// Listen for connectivity changes and reload ad when internet is restored
  void _startConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hadInternet = _hasInternet;
      _hasInternet = _checkHasInternet(results);

      if (kDebugMode) {
        print('[AdBannerWidget] Connectivity changed: $_hasInternet (was: $hadInternet)');
      }

      // If internet was restored and ad is not loaded, try to load ad
      if (!hadInternet && _hasInternet && !_isAdLoaded && !_isAdLoading) {
        if (kDebugMode) {
          print('[AdBannerWidget] Internet restored, loading ad...');
        }
        _loadBannerAd();
      }
    });
  }

  Future<void> _loadBannerAd() async {
    if (_isAdLoading || _isAdLoaded) return;

    if (kDebugMode) {
      print('[AdBannerWidget] Starting to load banner ad...');
    }

    setState(() {
      _isAdLoading = true;
    });

    try {
      _bannerAd = _adMobService.loadBannerAd(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: _onAdFailedToLoad,
      );
    } catch (e) {
      _errorMessage = 'Error loading banner ad: $e';
      setState(() {
        _isAdLoading = false;
      });
      if (kDebugMode) {
        print('[AdBannerWidget] $_errorMessage');
      }
    }
  }

  void _onAdLoaded(Ad ad) {
    if (kDebugMode) {
      print('[AdBannerWidget] Banner ad loaded successfully');
    }
    setState(() {
      _isAdLoaded = true;
      _isAdLoading = false;
      _errorMessage = null;
    });
  }

  void _onAdFailedToLoad(Ad ad, LoadAdError error) {
    if (kDebugMode) {
      print('[AdBannerWidget] Banner ad failed to load: ${error.message}');
    }
    setState(() {
      _isAdLoaded = false;
      _isAdLoading = false;
      _errorMessage = error.message;
    });
  }

  Future<void> _reloadBannerAd() async {
    setState(() {
      _isAdLoaded = false;
      _isAdLoading = false;
    });
    await _loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Loading state (only show if has internet)
    if (_hasInternet && (_isAdLoading || (!_isAdLoaded && _errorMessage == null && _bannerAd == null))) {
      return Container(
        width: double.infinity,
        height: widget.height,
        margin: widget.padding,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              _isAdLoading ? 'Loading ad...' : 'Preparing ad...',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Error state (only show if has internet)
    if (_errorMessage != null && !_isAdLoaded && _hasInternet) {
      return Container(
        width: double.infinity,
        height: widget.height,
        margin: widget.padding,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: colorScheme.error,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Ad unavailable',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _reloadBannerAd,
              icon: Icon(Icons.refresh, size: 14, color: colorScheme.primary),
              label: Text(
                'Retry',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );
    }

    // No internet case - don't show ad banner
    if (!_hasInternet) {
      return const SizedBox.shrink();
    }

    // No ad case
    if (!_adMobService.shouldShowAds() || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Ad display
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showDivider)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        Padding(
          padding: widget.padding,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: widget.height - widget.padding.vertical,
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}