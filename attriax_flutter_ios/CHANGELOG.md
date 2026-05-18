# Changelog

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