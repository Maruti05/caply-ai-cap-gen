import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class AdBannerWidget extends StatefulWidget {
  final EdgeInsets padding;
  final bool showDivider;

  const AdBannerWidget({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.showDivider = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdMobService _adMobService = AdMobService();

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadAd();
  });
    
  }

  Future<void> _loadAd() async {
    if (_isLoading || _isLoaded) return;

    _isLoading = true;
    _safeSetState();

    try {
      final width = MediaQuery.of(context).size.width;
      final size = await AdMobService.getAdaptiveSize(width);

      if (size == null) {
        if (kDebugMode) print('[AdBanner] Adaptive size null');
        return;
      }

      _bannerAd = BannerAd(
        adUnitId: AdMobService.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (_isDisposed) return;

            if (kDebugMode) print('[AdBanner] Loaded');

            _isLoaded = true;
            _isLoading = false;
            _safeSetState();
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();

            if (_isDisposed) return;

            if (kDebugMode) {
              print('[AdBanner] Failed: ${error.code} ${error.message}');
            }

            _isLoaded = false;
            _isLoading = false;
            _safeSetState();

            /// Retry (lightweight)
            Future.delayed(const Duration(seconds: 5), _loadAd);
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      if (kDebugMode) print('[AdBanner] Error: $e');
      _isLoading = false;
      _safeSetState();
    }
  }

  void _safeSetState() {
    if (!_isDisposed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _adMobService.disposeBannerAd(_bannerAd);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    /// Hide completely if no ad
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showDivider)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        Padding(
          padding: widget.padding,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
      ],
    );
  }
}