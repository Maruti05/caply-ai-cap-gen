import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentManager {
  static final ConsentInformation _consentInformation =
      ConsentInformation.instance;

  static Future<void> requestConsent() async {
    final params = ConsentRequestParameters();

    _consentInformation.requestConsentInfoUpdate(
      params,
      () async {
        if (await _consentInformation.isConsentFormAvailable()) {
          await _loadAndShowForm();
        }
      },
      (FormError error) {
        if (kDebugMode) debugPrint('Consent error: ${error.message}');
      },
    );
  }

  static Future<void> _loadAndShowForm() async {
    await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
      if (error != null && kDebugMode) {
        debugPrint('Consent form error: ${error.message}');
      }
    });
  }

  static Future<bool> canShowAds() async {
    try {
      return await _consentInformation.canRequestAds();
    } catch (_) {
      return true;
    }
  }
}
