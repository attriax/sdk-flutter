# Changelog

## 0.2.0

### Added
- `Attriax.skan` state and conversion-value update helpers, plus persisted server-driven SKAdNetwork schema/state handling for Apple-platform attribution flows.
- Shared `AttriaxAnalyticsEventKeys` and `AttriaxAnalyticsParamKeys` exports so apps, dashboard funnels, and SKAN rules can share the same event vocabulary.
- Browser-action aware deep-link resolution with automatic in-app or external URL handling on supported mobile platforms.
- A rebuilt public example app with Firebase/share integration, push-token registration flows, deep-link inspection, and richer startup/runtime coverage.

### Changed
- Breaking: `recordDeepLink()` now returns the completed `AttriaxDeepLinkEvent?` instead of the lower-level `AttriaxDeepLinkResolution?` wrapper.
- Breaking: deeplinks are now reworked, the stream returns already resolved events, while you can use rawStream for the install raw AppLink events.
- Events are now enhanced, look for the new `AttriaxAnalyticsEventKeys` and `AttriaxAnalyticsParamKeys` exports for the shared event vocabulary. Useful for SKAN conversion-value rules and consistent event naming across your app and the dashboard.
- Startup app-open monitoring now waits for the app-open lifecycle to settle before resolving deferred deep links and session referrers.
- ATT startup/request handling now waits for the real platform authorization result before continuing advertising-ID dependent native context collection.

### Fixed
- macOS startup no longer triggers a login-keychain permission prompt when the SDK restores or creates its stable device identifier.

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