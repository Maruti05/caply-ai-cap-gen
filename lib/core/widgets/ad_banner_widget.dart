import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class AdBannerWidget extends StatefulWidget {
  final EdgeInsets padding;
  final bool showDivider;

  const AdBannerWidget({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
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
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  Future<void> _loadAd() async {
    if (_isLoading || _isLoaded || _isDisposed) return;

    _isLoading = true;
    _safeSetState();

    try {
      final width = MediaQuery.of(context).size.width;
      final adaptiveSize = await AdMobService.getAdaptiveSize(width);
      final size = adaptiveSize ?? AdMobService.fallbackSize;

      _bannerAd = _adMobService.createBannerAd(
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (_isDisposed) return;
            _isLoaded = true;
            _isLoading = false;
            _retryCount = 0;
            _safeSetState();
            if (kDebugMode) debugPrint('[AdBanner] Loaded');
          },
          onAdFailedToLoad: (_, error) {
            if (_isDisposed) return;
            _bannerAd = null;
            _isLoaded = false;
            _isLoading = false;
            if (kDebugMode) {
              debugPrint('[AdBanner] Failed: ${error.code} ${error.message}');
            }
            _safeSetState();
            _scheduleRetry();
          },
          onAdImpression: (_) {
            if (kDebugMode) debugPrint('[AdBanner] Impression');
          },
        ),
      );
    } catch (e) {
      if (!_isDisposed) {
        _isLoading = false;
        _safeSetState();
      }
      if (kDebugMode) debugPrint('[AdBanner] Error: $e');
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_isDisposed || _retryCount >= _maxRetries) {
      if (kDebugMode) debugPrint('[AdBanner] Max retries reached, giving up');
      return;
    }
    _retryCount++;
    const delays = [5, 15, 45];
    final seconds = delays[_retryCount - 1];
    if (kDebugMode) {
      debugPrint('[AdBanner] Retry $_retryCount/$_maxRetries in ${seconds}s');
    }
    Future.delayed(Duration(seconds: seconds), () {
      if (!_isDisposed) _loadAd();
    });
  }

  void _safeSetState() {
    if (!_isDisposed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    _adMobService.disposeBannerAd(_bannerAd);
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

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
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
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
