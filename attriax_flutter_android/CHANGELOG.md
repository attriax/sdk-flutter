# Changelog

## 0.6.0

### Changed
- Re-wrapped as a thin binding over the shared Attriax Kotlin Multiplatform core; the Android-specific engine implementation was retired. No Android-only public API changes are required.
- The core is now resolved from Maven Central (`com.attriax:core:0.6.0`), so no local publish step is needed to build the plugin.
- Runtime permissions are inherited from the core AAR manifest instead of being declared here.

### Fixed
- `validateReceipt(...)` and `createDynamicLink(...)` threw on Android; the plugin now forwards both to the engine.

## 0.5.0

### Changed
- Package version alignment for the federated 0.5.0 release (best-effort app-open, retry backoff, session/consent refinements, and the slimmed receipt-validation and required-`projectToken`/`uri` API changes). No Android-only public API changes are required.

## 0.4.1

### Changed
- Package version alignment for the federated 0.4.1 GDPR config simplification release (the deprecated GDPR auto-detection toggle removed from shared config).

## 0.4.0

### Changed
- Package version alignment for the federated 0.4.0 grouped-tracking and anonymous-GDPR release. No Android-only public API changes are required.

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