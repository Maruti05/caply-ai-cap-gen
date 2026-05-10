import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
class ConsentManager {
  static final ConsentInformation _consentInformation =
      ConsentInformation.instance;

  static Future<void> requestConsent() async {
    final params = ConsentRequestParameters();

    final completer = Completer<void>();

    _consentInformation.requestConsentInfoUpdate(
      params,
      () async {
        // Success callback
        if (await _consentInformation.isConsentFormAvailable()) {
          await _loadAndShowForm();
        }
        completer.complete();
      },
      (FormError error) {
        // Error callback
        print('Consent info update error: ${error.message}');
        completer.complete();
      },
    );

    return completer.future;
  }

  static Future<void> _loadAndShowForm() async {
    final completer = Completer<void>();

    ConsentForm.loadAndShowConsentFormIfRequired(
      (FormError? error) {
        if (error != null) {
          print('Consent form error: ${error.message}');
        }
        completer.complete();
      },
    );

    return completer.future;
  }

  static Future<bool> canShowAds() async {
    return await _consentInformation.canRequestAds();
  }
}