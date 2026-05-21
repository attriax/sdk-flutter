# Changelog

## 0.3.0

### Changed
- Package version alignment for the federated 0.3.0 GDPR consent release. No Android-only API changes are required.

## 0.2.0

### Added
- Native `openBrowserUrl` handling for backend-provided deep-link browser actions, including an embedded `AttriaxInAppBrowserActivity` for in-app presentation.

### Changed
- Android deep-link handling can now follow resolved browser actions automatically through the shared platform-interface browser hook.

## 0.1.0

### Added
- Method-channel regression coverage for Android native context and install-referrer calls.

### Changed
- Package version alignment for the reinstall-attribution Flutter SDK release.
- Android install-referrer collection now feeds the richer startup attribution contract used by `attriax_flutter`.
- README now documents the wrapper/native handler split and the package-level validation command.

### Fixed
- Package-level lint configuration now ships with the publishable package.

## 0.0.1

- First public Android implementation release for the Attriax Flutter SDK.
- Added native install referrer and Android-specific context collection.