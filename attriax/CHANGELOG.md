# Changelog

## 0.1.0

### Added
- `Attriax.referrer` with original-install, reinstall, session, and latest deep-link lookup methods.
- Reinstall attribution and app-data-clear install-state support in the app-open runtime flow.
- Canonical deep-link URI, UTM, and backend registration metadata on startup/deep-link referrer payloads.

### Changed
- Breaking: removed the public `Attriax.installReferrer` getter in favor of `Attriax.referrer.*` async methods.
- Initial deep-link startup handling now returns the startup event and resolves it explicitly through `AttriaxDeepLinkEvent.resolve()`.
- Startup attribution persistence now stores original-install and reinstall referrers separately.
- Deferred deep links are no longer emitted for app-data-clear launches.

## 0.0.2

### Added
- Windows support through the new federated `attriax_flutter_windows` package.
- Updated SDK request and response contract coverage for app opens, deep-link resolution, sessions, crashes, and uninstall token registration.
- Stronger package example coverage for app-open state updates and matched deep-link navigation.

### Changed
- Public docs and the package example now include Windows-focused setup and validation guidance.

## 0.0.1

- First public Attriax Flutter SDK release.
- Added typed SDK transport models, offline queueing, synchronization state,
  deep-link callbacks, and a public example app.