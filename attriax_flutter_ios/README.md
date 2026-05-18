# attriax_flutter_ios

iOS and macOS implementation of the Attriax plugin.

This package is a federated implementation detail. Most apps should depend on
`attriax_flutter`, not `attriax_flutter_ios` directly.

## Overview

This package provides the Apple-platform implementation for the Attriax SDK.
It exists so the federated `attriax_flutter` package can resolve iOS and macOS support
from pub.dev. Most app teams should not import `attriax_flutter_ios` directly.

## Requirements

- Dart `^3.8.0`
- Flutter `>=3.29.0`
- iOS 13.0+
- macOS support through the same federated Apple implementation package

These floors match the package `pubspec.yaml`, the bundled Apple plugin code,
and the privacy-manifest/runtime setup documented in the main `attriax_flutter` README.

## Architecture

- Plugin class: `AttriaxIosPlugin`
- Platforms: iOS 13.0+, macOS
- Language: Swift
- Dart wrapper: `lib/src/attriax_flutter_ios.dart`
- Native handlers: `ios/Classes/AttriaxIosPlugin.swift`, `macos/Classes/AttriaxIosPlugin.swift`
- Bundled privacy manifests: `ios/Resources/PrivacyInfo.xcprivacy`, `macos/Resources/PrivacyInfo.xcprivacy`

## Privacy Manifest And Store Disclosures

This package bundles Apple privacy manifests for the SDK-owned native code on
iOS and macOS.

- The iOS manifest declares SDK-owned `Device ID` and `Crash Data` collection
  plus the required-reason `UserDefaults` access used for pending crash report
  persistence.
- The macOS manifest declares SDK-owned `Device ID` collection.
- The manifests intentionally leave tracking domains out of the package because
  Attriax host names are app-specific and are configured by the integrating
  app.
- If an iOS app ships with `collectAdvertisingId` enabled, the host app must
  still add the matching tracking domains, ATT purpose string, and App Store
  privacy labels for its configured Attriax host and consent flow.
- App Store privacy labels, ATT purpose strings, and any app-level tracking
  declarations still belong to the host app and must match the shipped Attriax
  configuration.

## Development

### Prerequisites

- Xcode ≥ 14
- iOS SDK ≥ 13.0
- Swift ≥ 5.0

### Validation

Validate this package from a macOS machine before release. Universal links,
foreground/background startup behavior, keychain reads, and App Store privacy
disclosures must be verified on Apple hardware as part of the release
checklist.

Run the package-level regression tests before release:

```bash
cd sdk-flutter/attriax_flutter_ios
flutter test
```

Unlike Android, Apple platforms do not provide an install-referrer API, so
release validation should focus on link delivery, initial app-open attribution,
and device-context collection.

### File Structure

```
ios/
  ├── attriax_flutter_ios.podspec    # CocoaPods specification
  ├── Classes/              # Swift implementation
  └── Resources/PrivacyInfo.xcprivacy
macos/
  ├── attriax_flutter_ios.podspec    # CocoaPods specification
  ├── Classes/               # Swift implementation
  └── Resources/PrivacyInfo.xcprivacy
lib/
  ├── attriax_flutter_ios.dart
  └── src/attriax_flutter_ios.dart
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
