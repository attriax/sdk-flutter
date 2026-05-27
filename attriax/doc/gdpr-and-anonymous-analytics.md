# GDPR And Anonymous Analytics

This package provides technical controls that help a Flutter app implement GDPR-friendly tracking. It is not legal advice, and it does not replace your consent UI, privacy policy, lawful-basis assessment, data processing terms, or regional compliance review.

## Consent Scope

Consent is regulation-scoped. GDPR lives under `attriax.consent.gdpr`, so future regulations can be added without changing the GDPR API shape.

GDPR consent has these states:

- `unknown`: no local or remote decision is available yet.
- `pending`: GDPR consent appears required and the app should ask the user.
- `granted`: a user decision has been recorded, including category values.
- `notRequired`: GDPR consent is not required for this app session or install.

Use `state`, `values`, and `isWaitingForConsent` to drive privacy UI. Use `needsConsent(localOnly: true)` for a local timezone-based precheck, and `needsConsent()` when the app can call the API for the server-side region decision.

## Pending Consent

When GDPR is enabled and the state is `unknown` or `pending`, the Flutter SDK does not restore or generate Attriax device identity yet. It keeps startup context minimal and waits to collect the full identified device snapshot until consent is granted, consent is not required, or GDPR handling is disabled.

With `anonymousTracking: true` (the default), anonymous-capable event, crash, session, and deep-link traffic is still sent immediately without `deviceId` or `deviceIdSource`. That keeps aggregate activity visible even before the app has resolved whether consent is required or before the user makes a choice.

With `anonymousTracking: false`, the same anonymous-capable traffic is captured locally and buffered in memory until consent resolves. If consent later grants the relevant category, the buffered traffic is promoted to identified delivery. If consent denies that category, the SDK drops the buffered traffic instead of sending it anonymously.

Attribution-only activity, user identity updates, uninstall tokens, and app-open attribution are not sent while consent is waiting.

## Consent Records

GDPR consent check and write requests use an SDK-generated consent ID. They do not send `deviceId`, `deviceIdSource`, app-user ID, external user ID, IP address, or user-agent as request-body consent identifiers.

Like any HTTPS API, the backend receives network metadata such as source IP and user-agent. GDPR consent checks may use that request context transiently for region decisions. It is not stored on consent records.

The backend consent record is keyed by app and consent ID. It stores the consent state, optional category values, region metadata, and timestamps. It is intentionally not linked to a tracked device or app user.

## Category Behavior

When consent is granted for a category, matching SDK requests can include device identity where the request type requires identified tracking.

When previously anonymous Flutter activity exists for the current installation, the SDK sends an immediate identified session heartbeat after consent resolves so the backend can promote the existing anonymous app-user record. The backend matches by the current SDK session ID first and falls back to the daily salted request-context hash when no same-session match exists.

When analytics or ad-events consent is denied after an unresolved period, analytics-capable activity may still be sent without device identity if your integration leaves anonymous tracking enabled. Treat that as a separate lawful-basis/product decision in your consent and privacy design.

Attribution, user identity, uninstall tracking, and install attribution require attribution consent. If attribution is denied, those requests are withheld rather than anonymized.

When all granted categories are effectively off and the SDK is only allowed to emit anonymous-capable traffic, the Flutter runtime falls back to consent-only persistence. GDPR consent state remains persisted, but runtime-scoped identifiers and queue/session state are cleared from persistent storage.

## Anonymous Analytics

Anonymous analytics means the SDK does not send Attriax device identity, app-user identity, or external user identity. It is not a promise of irreversible legal anonymization by itself.

Anonymous traffic is bound server-side to anonymous app users and sessions, not to device IDs. The backend derives a daily salted hash from request context and app ID, then groups anonymous events, crashes, sessions, and deep-link diagnostics under that anonymous identity. Raw IP and user-agent values are not stored in anonymous rows.

Daily salts limit long-term linkability and are pruned after a short operational window. While a salt exists, anonymous session data should still be treated as daily-scoped pseudonymous data for GDPR analysis. Anonymous analytics is useful for aggregate counts, trends, crash volume, and deep-link diagnostics, but it intentionally does not support user explorer history, uninstall tracking, cross-day identity stitching, or attribution decisions.

Website integrations can rely on the shared JS SDK GDPR flow instead of a separate anonymous fallback path. When only anonymous analytics remains allowed, the SDK can dispatch anonymous-capable traffic without persistent device identity storage.

## App Responsibilities

Your app should:

- Enable GDPR handling only when you want the SDK to gate GDPR-regulated tracking.
- Decide whether the default `anonymousTracking: true` behavior matches your privacy posture, or whether your app should buffer anonymous-capable traffic locally until consent resolves.
- Present clear consent UI before calling `setConsent`.
- Store and expose privacy choices in your app settings.
- Call `reset()` when the app needs to re-ask.
- Call `requestDataErasure()` when the user requests anonymization of previously tracked SDK data for the current installation.
- Avoid putting personal data, secrets, or direct identifiers in event names, metadata, page names, crash reasons, or custom properties unless you have an appropriate lawful basis.
