# Changelog

All notable changes to the Attriax Flutter SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-05-21

### Added
- Regulation-scoped GDPR consent APIs under `attriax.consent.gdpr`, including local and remote `needsConsent()` checks, explicit category decisions, `setNotRequired()`, and `reset()`.
- Consent-id-only GDPR check/write transport models in the generated `attriax_api_client` package.
- Anonymous analytics-capable dispatch for denied analytics paths without attaching Attriax device identity or app-user identity.
- Package-local GDPR and anonymous analytics documentation plus a simple custom consent prompt in the public Flutter example app.

### Changed
- GDPR-enabled runtimes now defer network dispatch while consent is pending and resume only after consent resolves to granted or not required.
- Requests buffered while GDPR is pending now regain device identity before dispatch when the final GDPR state is not required.
- Attribution, user identity, uninstall-token, and app-open attribution paths are withheld until attribution consent is granted or GDPR is not required.
- Analytics, crash, session, and deep-link diagnostics can use the anonymous/no-device path when the corresponding identified category is denied.

## [0.2.0] - 2026-05-18

### Added
- `attriax.skan` runtime support for Apple platforms, including conversion-value updates, server-driven SKAdNetwork schema/state handling, and shared analytics key exports for aligning app events with dashboard and SKAN rules.
- Browser-action aware deep-link resolution with automatic in-app or external URL opening on Android and iOS when Attriax resolves a browser destination.
- A rebuilt public example app with Firebase/share integration, push-token flows, deep-link inspection, and broader startup/runtime integration coverage.

### Changed
- Breaking: `Attriax.recordDeepLink()` now resolves to `AttriaxDeepLinkEvent?` after browser and deferred handling instead of the lower-level `AttriaxDeepLinkResolution?` wrapper.
- Breaking: deeplinks are now reworked, the stream returns already resolved events, while you can use rawStream for the install raw AppLink events.
- Events are now enhanced, look for the new `AttriaxAnalyticsEventKeys` and `AttriaxAnalyticsParamKeys` exports for the shared event vocabulary. Useful for SKAN conversion-value rules and consistent event naming across your app and the dashboard.
- Startup app-open monitoring now waits for the app-open lifecycle before resolving deferred deep links and session referrers.
- Apple ATT handling now waits for the platform authorization result before continuing advertising-ID dependent startup work.
- The generated `attriax_api_client` package now uses cleaner `json_serializable` transport models instead of the older `built_value`-based output.

### Fixed
- macOS SDK startup now uses the data-protection keychain path to avoid login-keychain permission popups while restoring the SDK device identity.

## [0.1.0] - 2026-05-13

### Added
- Reinstall attribution and app-data-clear classification in the Flutter SDK app-open flow.
- A dedicated `referrer` facade with original-install, reinstall, session, and latest deep-link lookups.
- Richer deep-link and startup-referrer payloads with canonical URIs, UTM data, and Android install-referrer timestamps.

### Changed
- Breaking: removed the public `Attriax.installReferrer` getter in favor of `Attriax.referrer.*` async methods.
- Startup deep-link handling now exposes the initial event first and lets callers resolve it explicitly, matching the foreground stream flow.
- Deferred deep-link startup handling now suppresses app-data-clear launches while still surfacing reinstall attribution.
- Federated Flutter packages and the generated Dart API client now release as `0.1.0` together.

## [0.0.2] - 2026-05-10

### Added
- Windows support through the new federated `attriax_flutter_windows` package.

## [0.0.1] - 2026-05-08

### Added
- First public-ready Attriax Flutter SDK release
- Federated plugin architecture with Android and iOS platform packages
- Dart-side support for web and desktop collection paths
- Versioned SDK request payloads with app and package version reporting
- Public example app and internal tester app
