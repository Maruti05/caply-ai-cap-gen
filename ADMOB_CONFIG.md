# AdMob Configuration Quick Reference

## 🎯 Where to Update IDs

Use this checklist to ensure all AdMob IDs are replaced correctly.

### Android Configuration

**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Line ~5 -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYYYYYY"/>
    ↑ Replace with your Android App ID
```

### iOS Configuration

**File**: `ios/Runner/Info.plist`
```xml
<!-- Near end of file -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYYYYYY</string>
                ↑ Replace with your iOS App ID
```

### Flutter App Configuration

**File**: `lib/core/services/admob_service.dart`
```dart
// Line ~18
static const String _androidBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYYYYYY';
                                            ↑ Replace with Android Banner Ad Unit ID

// Line ~19
static const String _iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYYYYYY';
                                        ↑ Replace with iOS Banner Ad Unit ID
```

## 🔍 ID Format Reference

| ID Type | Format | Example |
|---------|--------|---------|
| App ID | `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYYYYYY` | `ca-app-pub-3940256099942544~1458002681` |
| Ad Unit ID | `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYYYYYY` | `ca-app-pub-3940256099942544/6300978111` |

## 🧪 Test Ad Unit IDs (for development)

Use these IDs for testing - they're provided by Google and won't affect your AdMob account:

```dart
// Banner Ads (320x50)
Android:  ca-app-pub-3940256099942544/6300978111
iOS:      ca-app-pub-3940256099942544/2934735716

// Test Device IDs (if needed)
Emulator: EMULATOR
```

## ✅ Verification Checklist

- [ ] Google AdMob account created
- [ ] App added to AdMob console
- [ ] Android App ID generated
- [ ] iOS App ID generated
- [ ] Android Banner Ad Unit ID generated
- [ ] iOS Banner Ad Unit ID generated
- [ ] `build.gradle.kts` has no changes needed (already configured)
- [ ] `AndroidManifest.xml` updated with App ID
- [ ] `Info.plist` updated with App ID
- [ ] `admob_service.dart` updated with Ad Unit IDs
- [ ] Tested with test ad units first
- [ ] Switched to production ad units
- [ ] App published and monitored

## 🚀 Testing Workflow

```
1. Use Test Ad Unit IDs in admob_service.dart
   ↓
2. Build and run on Android/iOS
   ↓
3. Verify ads load with "[AdMob] Banner ad loaded successfully" message
   ↓
4. Replace with Production Ad Unit IDs
   ↓
5. Test again
   ↓
6. Build release APK/IPA
   ↓
7. Wait 24-48 hours for ads to appear in production
```

## 📋 Default Locations (Already Set Up)

- ✅ Internet permission: `android/app/src/main/AndroidManifest.xml` (included)
- ✅ google_mobile_ads dependency: `pubspec.yaml` (version ^8.0.0)
- ✅ AdMob initialization: `lib/main.dart` (already called)
- ✅ Provider setup: `lib/main.dart` (already configured)
- ✅ Banner widget: `lib/core/widgets/ad_banner_widget.dart` (ready to use)
- ✅ Tab integration: All tabs updated with banner widgets

## 💡 Pro Tips

1. **Use Test IDs First**: Always develop with test ad unit IDs to avoid penalties
2. **Check Console**: Watch for `[AdMob]` prefixed log messages for debugging
3. **Ad Approval**: After publishing, wait 24-48 hours before live ads appear
4. **Account Health**: Monitor AdMob dashboard for policy violations
5. **Multiple Units**: You can create separate ad units for each tab if desired

## 🔗 Resources

- AdMob Console: https://admob.google.com
- Get Test IDs: https://developers.google.com/admob/android/test-ads
- Flutter Plugin Docs: https://pub.dev/packages/google_mobile_ads
- AdMob Policies: https://support.google.com/admob/answer/9905175

---

**Note**: Replace all instances of `XXXXXXXXXXXXXXXX` and `YYYYYYYYYYYYYY` with your actual IDs from Google AdMob console.
