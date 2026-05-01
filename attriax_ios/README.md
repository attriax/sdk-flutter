# attriax_ios

iOS and macOS implementation of the Attriax plugin.

This package is a federated implementation detail. Most apps should depend on
`attriax`, not `attriax_ios` directly.

## Overview

This package provides the Apple-platform implementation for the Attriax SDK.

## Architecture

- Plugin class: `AttriaxIosPlugin`
- Platforms: iOS 13.0+, macOS
- Language: Swift
- Dart wrapper: `lib/src/attriax_ios.dart`
- Native handlers: `ios/Classes/AttriaxIosPlugin.swift`, `macos/Classes/AttriaxIosPlugin.swift`

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
cd flutter-plugin/attriax_ios
flutter test
```

Unlike Android, Apple platforms do not provide an install-referrer API, so
release validation should focus on link delivery, initial app-open attribution,
and device-context collection.

### File Structure

```
ios/
  ├── attriax_ios.podspec    # CocoaPods specification
  └── Classes/              # Swift implementation
macos/
  └── Classes/              # Swift implementation
lib/
  ├── attriax_ios.dart
  └── src/attriax_ios.dart
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
