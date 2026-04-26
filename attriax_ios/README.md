# attriax_ios

iOS implementation of the Attriax plugin.

This package is a federated implementation detail. Most apps should depend on
`attriax`, not `attriax_ios` directly.

## Overview

This package provides the iOS platform implementation for the Attriax SDK.

## Architecture

- Plugin class: `AttriaxIosPlugin`
- Platform: iOS 13.0+
- Language: Swift

## Development

### Prerequisites

- Xcode ≥ 14
- iOS SDK ≥ 13.0
- Swift ≥ 5.0

### Validation

Validate this package from a macOS machine before release. Universal links,
foreground/background startup behavior, and App Store privacy disclosures must
be verified on real iOS hardware as part of the release checklist.

### File Structure

```
ios/
  ├── attriax_ios.podspec    # CocoaPods specification
  └── Classes/              # Swift implementation
lib/
  ├── attriax_ios.dart
  └── src/attriax_ios.dart
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
