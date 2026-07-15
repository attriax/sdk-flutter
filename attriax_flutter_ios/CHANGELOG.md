# Changelog

## 0.6.0

### Added
- Swift Package Manager support: `Package.swift` manifests for the iOS and macOS plugins. Flutter 3.44 makes SwiftPM the default; the podspecs are kept as the CocoaPods fallback for older Flutter versions.

### Changed
- Re-wrapped as a thin binding over the shared Attriax Kotlin Multiplatform core; the Apple-specific engine implementation was retired. No Apple-only public API changes are required.

### Fixed
- `recordAdEvent` was not resolved from the `eventName` wire key and did not reach the engine.

## 0.5.0

### Changed
- Package version alignment for the federated 0.5.0 release (best-effort app-open, retry backoff, session/consent refinements, and the slimmed receipt-validation and required-`projectToken`/`uri` API changes). No Apple-only public API changes are required.

## 0.4.1

### Changed
- Package version alignment for the federated 0.4.1 GDPR config simplification release (the deprecated GDPR auto-detection toggle removed from shared config).

## 0.4.0

### Changed
- Package version alignment for the federated 0.4.0 grouped-tracking, anonymous-GDPR, and data-erasure release. No Apple-only public API changes are required.

## 0.3.0

### Added
- Native context collection now includes the precise Apple hardware model identifier where available for richer device diagnostics.

### Changed
- Package version alignment for the federated 0.3.0 GDPR consent release.

## 0.2.0

### Added
- Native browser-action handling via `SFSafariViewController` or the system browser when Attriax resolves a deep link to a browser destination.
- SKAdNetwork conversion-value updates, coarse values, and lock-window support through the federated iOS/macOS implementation.

### Changed
- `requestTrackingAuthorization()` now waits for the real ATT callback before returning to Dart, keeping startup advertising-ID collection aligned with the user's choice.
- Updated iOS and macOS privacy manifests for the new SKAdNetwork and SDK-owned device-id collection behavior.

### Fixed
- macOS keychain reads now use the data-protection keychain path to avoid login-keychain permission prompts during SDK startup.

## 0.1.0

### Changed
- Package version alignment for the reinstall-attribution Flutter SDK release.
- iOS and macOS builds now ship with the updated platform-interface contract used by `attriax_flutter` 0.1.0.
- README now documents the wrapper/native handler split and the iOS-specific release validation focus.

### Added
- Method-channel regression coverage for iOS native context and install-referrer fallbacks.

### Fixed
- Package-level lint configuration now ships with the publishable package.

## 0.0.1

- First public iOS implementation release for the Attriax Flutter SDK.
- Added native iOS device, locale, screen, and power-state context collection.