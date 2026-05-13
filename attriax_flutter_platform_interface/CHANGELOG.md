# Changelog

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