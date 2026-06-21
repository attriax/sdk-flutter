# Changelog

All notable changes to the Attriax Flutter SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-06-15

### Added
- New canonical entrypoint `package:attriax_flutter/attriax.dart` that re-exports everything from `attriax_flutter.dart` (the old import remains a supported alias).
- Bot / automated-traffic detection on web: the SDK flags `isBot` and `botDetectedVia` in the device context (WebDriver, headless/zero-size screen, and known bot user agents).
- GDPR region detection now covers EU outermost territories whose timezones are outside `Europe/` (French Guiana, Guadeloupe, Saint-Martin, Martinique, Saint-Barthélemy, Mayotte, Réunion).
- Startup config validation: `init()` now rejects an empty `projectToken`, a non-positive `maxQueueSize`, and negative flush/ATT-timeout durations with an `ArgumentError`.

### Changed
- Breaking: `validateReceipt(...)` now takes a single `required String receipt` plus `test`, `provider`, `environment`, `productId`, and `transactionId`; the previous per-store fields (`originalTransactionId`, `store`, `packageName`, `purchaseToken`, `receiptData`, `signedPayload`, `receiptSignature`) were removed, and `receipt` must be non-empty.
- Breaking: `deepLinks.recordDeepLink(...)` now requires `uri`; the optional `linkPath` parameter was removed.
- Breaking: `AttriaxConfig` now requires `projectToken`; the deprecated `appToken` constructor alias and getter were removed.
- Breaking: `Attriax.init({bool? enabled})` no longer accepts an `enabled` argument; use `tracking.enabled` before or after `init()` to control event delivery.
- Breaking: tracking helpers (`recordEvent`, `recordPurchase`, `recordRefund`, `recordAdRevenue`, `recordAdEvent`, `recordPageView`, `recordError`, `setUser`, `setUserProperty`, `setUserProperties`, `clearUserProperties`) now return `void` (fire-and-forget) instead of `Future<void>`.
- Failed network requests now retry with a capped, jittered exponential backoff (2s base, 5min cap) when the server sends no usable `Retry-After`, instead of being re-flushed with no spacing; a `Retry-After` of `0` or negative also falls back to backoff rather than an immediate retry.
- Retryable HTTP statuses now include `408` (Request Timeout) and `425` (Too Early) in addition to `429` and all `5xx`.
- App-open (attribution) delivery is now best-effort and no longer gates other queued requests; events, sessions, and deep-link resolutions are dispatched without waiting for a successful app-open.
- Awaited manual deep-link resolution (`recordDeepLink`) is now time-bounded (30s) and throws `TimeoutException` if it does not complete, instead of hanging indefinitely while offline; the underlying request still follows the normal queue/retry policy.
- `referrer.getLatestDeepLinkReferrer()` now returns `null` immediately when no deep link has been handled yet, instead of waiting for the next deep-link event.
- Session continuation window is now clamped to a minimum of 60s and a maximum of 30min (previously twice the heartbeat interval, unbounded), so tiny first-launch heartbeats and oversized intervals no longer over- or under-continue sessions.
- Uninstall (push) token registration is now withheld while GDPR consent is still pending/unknown instead of being captured eagerly.
- In release builds the logger now emits only the level/message line and suppresses error objects, HTTP response bodies, and stack traces to avoid leaking sensitive payloads.

### Fixed
- A recovered session's inferred end time is now clamped to "now" so a continued session's end event can no longer postdate the replacing session's start, eliminating out-of-order session lifecycle events.
- A deep link tied to a known origin session no longer leaks into a different (or already-ended) current session; cold-start links with no origin session still attach to the current session.
- A no-op consent server sync that only refreshes region metadata or the checked-at timestamp no longer triggers a full queue rewrite and runtime reconfiguration; only an actual consent decision change does.
- Failures while observing startup referrers now resolve to "no referrer" (returning `null`) instead of surfacing a delivery error from the referrer getters.
- A failed app-open observation is now reported to observers as "no result" rather than escaping as an unhandled async exception.

## [0.4.1] - 2026-05-31

### Changed
- Breaking: removed the deprecated GDPR auto-detection toggle from the shared Flutter `AttriaxConfig`.
- Breaking: SDK runtimes no longer run timezone auto-detection automatically during init.
- Updated package docs/examples and federated package alignment notes for the 0.4.1 removal.

## [0.4.0] - 2026-05-27

### Added
- `attriax.tracking` as the focused Flutter facade for custom events, page views, revenue, ads, uninstall-token registration, user identity, and manual error reporting.
- `anonymousTracking` on `AttriaxConfig`, runtime `attriax.tracking.anonymousTrackingEnabled`, and `attriax.consent.gdpr.requestDataErasure()` for GDPR-erasure flows.
- A richer public demo app under `example-rich/` so the publishable package example can stay integration-focused.
- A dedicated `example-gdpr/` app for manual GDPR consent, anonymous-tracking, and data-erasure QA.

### Changed
- Breaking: removed the legacy top-level tracking, ad, revenue, uninstall-token, and identity methods from `Attriax`; use `attriax.tracking.*` instead.
- Breaking: moved the event-delivery toggle from `attriax.eventsEnabled` to `attriax.tracking.enabled`.
- Breaking: moved dynamic-link creation and manual deep-link forwarding from the root API to `attriax.deepLinks.createDynamicLink(...)` and `attriax.deepLinks.recordDeepLink(...)`.
- Breaking: removed the remaining root ATT aliases in favor of `attriax.consent.att.getTrackingAuthorizationStatus()` and `attriax.consent.att.requestTrackingAuthorization()`.
- GDPR-enabled runtimes now send anonymous-capable analytics, crash, session, and deep-link activity immediately by default while consent is unresolved, without materializing device identity. Set `anonymousTracking: false` to keep that work in memory until consent allows identified delivery.
- `validateReceipt(...)` stays on the root `Attriax` entrypoint and remains available even when tracking is disabled or GDPR consent is still pending.
- The package example now stays minimal and package-focused, while the broader demo surface lives in `example-rich/`.

### Fixed
- First-launch state now persists independently of device identity, so repeated unresolved-consent launches are no longer misclassified as a fresh install when consent-only persistence is active.
- Frontend setup snippets and Flutter-facing docs now reference the new facade-based API surface instead of the removed top-level methods.

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
- Breaking: `AttriaxDeepLinks.recordDeepLink()` now resolves to `AttriaxDeepLinkEvent?` after browser and deferred handling instead of the lower-level `AttriaxDeepLinkResolution?` wrapper.
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
