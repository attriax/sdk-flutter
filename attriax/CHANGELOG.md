# Changelog

## 0.6.0

### Added
- `attriax.consent.ccpa` (`AttriaxCcpaConsent`): `doNotSell` / `usPrivacy` getters plus `setDoNotSell`, `setUsPrivacy`, and `set`, seeded from `AttriaxConfig.doNotSell` / `usPrivacy` and overridable at runtime — mirroring the existing GDPR consent facade.
- Public `Attriax.flush()` to force delivery of everything currently queued.
- Linux desktop support through the new federated `attriax_flutter_linux` implementation.
- Swift Package Manager support for the iOS/macOS plugin. Flutter 3.44 makes SwiftPM the default; CocoaPods remains supported as a fallback for older Flutter versions.

### Changed
- Every supported platform now runs the shared Attriax native engine instead of a Flutter-only Dart engine: Android, iOS, macOS, Windows, and Linux bind to the shared Kotlin Multiplatform core, and web binds to the `@attriax/js` engine. The public Dart API is unchanged — no migration is required.
- `attriax_api_client` is no longer a dependency of this package and is now deprecated; the native engine performs its own transport.

### Fixed
- `deepLinks.rawInitialDeepLink` always returned `null`; it now caches the first raw deep-link event and seeds from the initial raw deep link.
- `validateReceipt(...)` and `createDynamicLink(...)` threw on Android; both are now handled by the Android implementation.

## 0.5.0

### Added
- New canonical entrypoint `package:attriax_flutter/attriax.dart` that re-exports everything from `attriax_flutter.dart` (the old import remains a supported alias).
- Bot / automated-traffic detection on web: the SDK flags `isBot` and `botDetectedVia` in the device context (WebDriver, headless/zero-size screen, and known bot user agents).
- GDPR region detection now covers EU outermost territories whose timezones are outside `Europe/` (French Guiana, Guadeloupe, Saint-Martin, Martinique, Saint-Barthélemy, Mayotte, Réunion).
- Startup config validation: `init()` now rejects an empty `projectToken`, a non-positive `maxQueueSize`, and negative flush/ATT-timeout durations with an `ArgumentError`.

### Changed
- Breaking: `validateReceipt(...)` now takes a single `required String receipt` plus `test`, `provider`, `environment`, `productId`, and `transactionId`; the previous per-store fields (`originalTransactionId`, `store`, `packageName`, `purchaseToken`, `receiptData`, `signedPayload`, `receiptSignature`) were removed, and `receipt` must be non-empty.
- Breaking: `deepLinks.recordDeepLink(...)` now requires `uri`; the optional `linkPath` parameter was removed.
- Breaking: `AttriaxConfig` now requires `projectToken`; the deprecated `appToken` constructor alias and getter were removed.
- The SDK now sends `projectToken` on the wire (and uses it throughout its internal transport) instead of the deprecated `appToken` alias; the backend still accepts `appToken` from already-released SDKs.
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

## 0.4.1

### Changed
- Breaking: removed the deprecated GDPR auto-detection toggle from `AttriaxConfig`
- Breaking: the SDK no longer runs timezone auto-detection automatically during init.
- Updated examples, tests, and docs to stop passing the removed config option.

## 0.4.0

### Added
- `Attriax.tracking` as the focused facade for custom events, page views, revenue, ads, uninstall-token registration, user identity, and manual error reporting.
- `anonymousTracking` on `AttriaxConfig`, `AttriaxTracking.anonymousTrackingEnabled` for runtime control, and `AttriaxConsentGdpr.requestDataErasure()` for GDPR-erasure flows.

### Changed
- Breaking: removed the legacy top-level tracking, ad, revenue, uninstall-token, and identity methods from `Attriax`; use `tracking.*` instead.
- Breaking: moved the event-delivery toggle from `eventsEnabled` to `tracking.enabled`.
- Breaking: moved dynamic-link creation and manual deep-link forwarding to `deepLinks.createDynamicLink(...)` and `deepLinks.recordDeepLink(...)`.
- Breaking: removed the remaining root ATT aliases in favor of `consent.att.*`.
- GDPR-enabled runtimes now send anonymous-capable analytics, crash, session, and deep-link activity immediately by default while consent is unresolved, without materializing device identity. Set `anonymousTracking` to `false` to keep that work in memory until consent allows identified delivery.

### Fixed
- First-launch state now persists independently of device identity, so unresolved-consent restarts are no longer treated as first launch.

## 0.3.0

### Added
- `Attriax.consent.gdpr` for regulation-scoped GDPR consent state, `needsConsent()` checks, `setConsent()`, `setNotRequired()`, and `reset()`.
- GDPR-aware tracking policy that queues network work while consent is pending and resumes after a granted or not-required decision.
- Anonymous analytics-capable delivery for denied analytics paths without sending Attriax device identity or app-user identity.
- Package-local GDPR and anonymous analytics documentation.
- A simple custom GDPR consent prompt on the public example home page, with the fuller controls still available from the Controls page.

### Changed
- App-open attribution, identity, uninstall-token, and attribution-sensitive deep-link work now require attribution consent when GDPR gating is enabled.
- Requests buffered while GDPR is pending now regain device identity before dispatch when the final GDPR state is not required.
- The public example app starts with `gdprEnabled: true` so clients can see the recommended consent flow in a real Flutter app.

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