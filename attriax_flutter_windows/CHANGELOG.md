# Changelog

## 0.6.0

### Changed
- Windows desktop is now a real platform implementation rather than a passthrough: the package binds to the shared Attriax Kotlin Multiplatform core through its C-ABI over `dart:ffi`, and the prebuilt `attriax_core.dll` is bundled with the app. No Windows-only public API changes are required.

### Fixed
- Event strings handed to the FFI callback are now freed via `attriax_free_string`, honoring the C-ABI caller-frees contract and removing a per-event leak.

## 0.5.0

### Changed
- Package version alignment for the federated 0.5.0 release (best-effort app-open, retry backoff, session/consent refinements, and the slimmed receipt-validation and required-`projectToken`/`uri` API changes).
- Removed redundant method overrides from the Windows platform implementation that duplicated the shared platform-interface defaults. No behavior change.

## 0.4.1

### Changed
- Package version alignment for the federated 0.4.1 GDPR config simplification release (the deprecated GDPR auto-detection toggle removed from shared config).

## 0.4.0

### Changed
- Package version alignment for the federated 0.4.0 grouped-tracking and anonymous-GDPR release. No Windows-only public API changes are required.

## 0.3.0

### Changed
- Package version alignment for the federated 0.3.0 GDPR consent release. No Windows-only API changes are required.

## 0.2.0

### Changed
- No runtime behavior changes in the Windows implementation; the package version is aligned with the federated 0.2.0 release and the package sources/tests were refreshed for the current lint/style rules.

## 0.1.0

### Changed
- Package version alignment for the reinstall-attribution Flutter SDK release.
- Windows builds now consume the richer reinstall-aware startup attribution and deep-link event models shipped by `attriax_flutter` 0.1.0.

## 0.0.1

- First Windows platform release for the Attriax Flutter plugin.
- Added the federated Windows package, C API registration surface, and native method-channel implementation.
- Added a Windows example app and package tests for platform version and native context collection.
