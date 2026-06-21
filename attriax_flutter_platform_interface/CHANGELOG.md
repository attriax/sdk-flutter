# Changelog

## 0.5.0

### Changed
- Breaking: `AttriaxConfig` now requires `projectToken`; the deprecated `appToken` constructor alias and getter were removed from the shared config.
- Bumped the shared `attriaxSdkPackageVersion` metadata to `0.5.0`.

## 0.4.1

### Changed
- Breaking: removed the shared deprecated GDPR auto-detection config field.
- Breaking: SDK runtimes no longer run timezone auto-detection automatically during init.
- Bumped shared SDK package metadata to `0.4.1`.

## 0.4.0

### Added
- `anonymousTracking` on the shared config and runtime types used by the main Flutter SDK and federated implementations.

### Changed
- Split the shared type surface into focused modules for platform runtime, links, deep-link lifecycle, session config, and SKAdNetwork models while keeping the federated contract aligned with `attriax_flutter` 0.4.0.
- Bumped the shared SDK package version metadata to `0.4.0`.

## 0.3.0

### Changed
- Bumped the shared SDK package version metadata to `0.3.0` for the GDPR consent release.

## 0.2.0

### Added
- `AttriaxResolvedUrlAction`, `AttriaxResolvedUrlOpenMode`, and browser-action payloads on deep-link and referrer models so the SDK can follow backend-provided browser destinations.
- `AttriaxSkanConfig`, `AttriaxSkanState`, `AttriaxSkanUpdateResult`, and the related SKAdNetwork schema/value models used by the Apple-platform runtime.
- New `AttriaxPlatform.openBrowserUrl()` and `AttriaxPlatform.updateSkanConversionValue()` hooks for federated implementations.

### Changed
- `AttriaxConfig` now exposes `automaticBrowserHandling` and `skan` configuration for the main SDK runtime.
- Method-channel regression coverage now includes browser-action handling and the expanded SKAdNetwork payload shapes.

## 0.1.0

### Added
- `AttriaxInstallState` and `AttriaxDeepLinkReferrerDetails` for reinstall-aware startup attribution and deep-link referrers.
- Richer install-referrer, deep-link, and app-open result models with canonical URI and UTM fields.
- Method-channel regression coverage for the default platform-interface implementation.

### Changed
- Breaking: consuming packages now use the `Attriax.referrer` facade instead of `Attriax.installReferrer`.
- Initial deep-link startup handling now returns a startup event that callers resolve explicitly.
- README now documents the package-level validation command for standalone release checks.

### Fixed
- Package-level lint configuration now ships with the publishable package.

## 0.0.1

- First public platform interface release for the Attriax Flutter SDK.
- Added shared SDK models, synchronization state types, and the federated
  platform contract used by the Android and iOS implementations.