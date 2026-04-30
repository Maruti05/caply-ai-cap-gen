# Google AdMob Integration Guide

This guide explains how to complete the Google AdMob implementation in your Caply app.

## 📋 Overview

The AdMob integration is now implemented across:
- **CaptionTab** (with banner ads)
- **BioTab** (with banner ads)
- **QuoteTab** (with banner ads)
- **SavedScreen** (no ads - as requested)
- **SettingsScreen** (no ads - as requested)

## 🔑 Getting Your AdMob IDs

### Step 1: Create a Google AdMob Account
1. Go to [Google AdMob](https://admob.google.com)
2. Sign in with your Google account
3. Click "Start" and follow the setup wizard

### Step 2: Create Your App
1. In AdMob console, click "Apps" → "Add app"
2. Enter: **App name**: Caply
3. Select: **Platform**: Android/iOS
4. You'll receive your **App ID** (format: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyyyyyy`)

### Step 3: Create Banner Ad Units
For each platform (Android and iOS), create banner ad units:

1. In your app settings, click "Ad units" → "Add ad unit"
2. Select **Ad format**: Banner
3. Enter **Name**: e.g., "Captions Banner", "Bios Banner", etc.
4. You'll receive **Ad Unit IDs** (format: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy`)

**Note**: You can reuse the same banner ad unit across all tabs.

## 🔧 Configuration

### Android Setup

#### 1. Replace App ID
Edit: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyyyyyy"/>
```
Replace the value with your **Android App ID**.

#### 2. Replace Banner Ad Unit ID
Edit: `lib/core/services/admob_service.dart`
```dart
static const String _androidBannerId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy';
```
Replace with your **Android Banner Ad Unit ID**.

### iOS Setup

#### 1. Replace App ID
Edit: `ios/Runner/Info.plist`
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyyyyyy</string>
```
Replace with your **iOS App ID**.

#### 2. Replace Banner Ad Unit ID
Edit: `lib/core/services/admob_service.dart`
```dart
static const String _iosBannerId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy';
```
Replace with your **iOS Banner Ad Unit ID**.

## 📱 Testing Ads

### Using Test Ads (Recommended First)
Google provides test ad unit IDs that don't count as impressions:

**Android Test Banner ID**: `ca-app-pub-3940256099942544/6300978111`
**iOS Test Banner ID**: `ca-app-pub-3940256099942544/2934735716`

Use these for initial testing. Replace with the values above in `lib/core/services/admob_service.dart` temporarily.

### Debugging
Check the console logs for AdMob initialization:
- `[AdMob] Initializing Google Mobile Ads SDK...`
- `[AdMob] Google Mobile Ads SDK initialized successfully`
- `[AdMob] Banner ad loaded successfully`

If you see load errors, check:
1. Ad unit IDs are correct
2. Internet permission is enabled (already in AndroidManifest.xml)
3. Test mode is working before switching to live ads

## 📊 Code Architecture

### File Structure
```
lib/
├── core/
│   ├── services/
│   │   └── admob_service.dart          # AdMob service
│   ├── providers/
│   │   └── admob_provider.dart         # State management
│   └── widgets/
│       └── ad_banner_widget.dart       # Reusable banner widget
└── features/
    └── tabs/
        ├── caption_tab.dart            # With banner ads
        ├── bio_tab.dart                # With banner ads
        └── quote_tab.dart              # With banner ads
```

### Key Components

#### 1. **AdMobService** (`lib/core/services/admob_service.dart`)
- Singleton service pattern - only one instance across the app
- Handles initialization, loading, and disposal of ads
- Platform-specific ad unit IDs
- Logging for debugging

#### 2. **AdMobProvider** (`lib/core/providers/admob_provider.dart`)
- Extends `ChangeNotifier` for state management with Provider
- Manages banner ad lifecycle
- Exposes loading state, loaded state, and error messages
- Auto-disposes resources on provider disposal

#### 3. **AdBannerWidget** (`lib/core/widgets/ad_banner_widget.dart`)
- Reusable Flutter widget for displaying ads
- Non-intrusive placement
- Handles visibility logic (only shows if ad loaded)
- Styled with theme support

#### 4. **Integration in Tabs**
- Banner placed at the top of each tab
- Content scrolls independently below the banner
- Ensures ads don't interfere with UX

## 🎨 Customization

### Adjust Ad Size
Edit `lib/core/widgets/ad_banner_widget.dart`:
```dart
height: 60  // Change banner height (default: 60)
```

### Remove Divider Lines
```dart
showDivider: false  // Hide top/bottom divider lines
```

### Conditional Ad Display
Edit `lib/core/services/admob_service.dart`:
```dart
bool shouldShowAds() {
  // Add logic for premium users, subscription checks, etc.
  return true; // Always show by default
}
```

## 📈 Best Practices

1. **Test Before Publishing**: Always test with test ad IDs first
2. **Monitor Performance**: Check AdMob dashboard for impressions and revenue
3. **User Experience**: Banner at top is least intrusive (your current setup)
4. **Frequency Capping**: Consider adding frequency caps to prevent ad fatigue
5. **Theme Consistency**: Ads automatically adapt to your light/dark theme
6. **Error Handling**: The code gracefully handles ad load failures

## 🚀 Next Steps (Optional Monetization)

Consider adding in the future:
- Interstitial ads (between screens)
- Rewarded ads (user gets something for watching)
- Native ads (custom ad format)
- Ad frequency caps
- Premium ad-free version

## ⚠️ Important Notes

- **Never Click Your Own Ads**: Google will ban your account for artificially inflating clicks
- **Test Ads**: Use test ad unit IDs from Google during development
- **Ad Review**: Wait 24-48 hours after publishing before ads appear in production
- **Policy Compliance**: Ensure your app complies with Google Play policies
- **Revenue**: AdMob typically pays 68% of revenue to developers, Google keeps 32%

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Ads not loading | Check ad unit IDs, verify internet permission |
| App crashing | Ensure all replacements made correctly |
| No impressions | Check app is in production (not debug), wait 24-48h |
| Blank banner | Ad loaded but creative not available yet, normal |
| Ads showing test data | You're using test ad unit IDs, that's correct for testing |

## 📞 Support

For issues:
1. Check [Google Mobile Ads SDK documentation](https://pub.dev/packages/google_mobile_ads)
2. Review [AdMob Help Center](https://support.google.com/admob)
3. Check console logs for specific error messages

---

**Version**: 1.0  
**Last Updated**: 2024  
**Framework**: Flutter 3.x with Provider package  
**Ad SDK**: google_mobile_ads 8.0.0+
