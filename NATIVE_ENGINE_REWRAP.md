# Flutter → native-engine re-wrap (architecture blueprint)

**Branch:** `feat/native-engine-rewrap`. Big restructuring — Flutter stops being a
Dart *engine* and becomes a thin *wrapper* over native engines, one per platform.

## Decision (2026-07-08)

- Flutter is a **pure thin wrapper**. The Dart engine (HTTP/queue/retry/consent/
  sessions/deep-links/sync) is **retired**.
- Engine per platform:
  | Platform | Native engine | Artifact |
  | --- | --- | --- |
  | Android | **KMP core** | `com.attriax:core-android` (AAR) |
  | iOS / macOS | **KMP core** | KMP XCFramework *(built at the Mac)* |
  | Windows / Linux | **KMP core** | KMP native lib (`core-mingwx64` / `core-linuxx64`) via FFI |
  | Web | **sdk-js** (`@attriax/js`) | JS interop (`dart:js_interop`) |
- This resolves the "KMP has no JS target" wrinkle: **web runs on sdk-js**, native
  platforms (incl. desktop) run on the KMP core. Every platform wraps a native
  engine; no engine logic remains in Dart.

## Current state (what we're inverting)

Already federated: `attriax` (app-facing Dart) · `attriax_flutter_platform_interface`
· `attriax_flutter_android` (Kotlin) · `attriax_flutter_ios` (Swift, ios+macos) ·
`attriax_flutter_windows` (C-API) · web `AttriaxWebPlugin` · `attriax_api_client`.

Today the **Dart layer is the engine**; the native packages are **thin signal
providers only** (`collectNativeContext`, `collectInstallReferrer`,
`requestTrackingAuthorization`, `updateSkanConversionValue`, `attest`, ASA
`acquireToken`, `openBrowserUrl`, `consumePendingCrashReport`,
`readAttributionClipboard`, `collectWebViewUserAgent`). The re-wrap **inverts**
this: the engine moves into native; the platform interface expands from *signals*
to the *full engine surface*; the Dart core is deleted.

## Target architecture

```
app code
  │  (unchanged public Dart API — backward compatible)
  ▼
attriax (Dart facade)              ← NO engine logic; forwards every call
  │
  ▼
attriax_flutter_platform_interface ← expanded: full engine command + event surface
  │        │              │              │
  ▼        ▼              ▼              ▼
android   ios/macos     windows/linux   web
(KMP AAR) (KMP XCFwk)   (KMP nativelib) (sdk-js)
  engine    engine        engine          engine
```

- **Public Dart API is unchanged** — `Attriax.init(config)`,
  `attriax.tracking.recordEvent(...)`, `attriax.consent.gdpr.*`,
  `attriax.deepLinks.*`, `attriax.synchronization.*`, `attriax.referrer.*`,
  `attriax.skan.*`, `attriax.consent.att.*`. Existing apps don't change.
- The facade holds **no state/logic**; it (de)serializes calls to the platform
  interface. The **native engine is authoritative** (identity, queue, consent,
  sessions all live there).

### Platform-interface contract (expanded)

Commands (Dart → native, async `Future`s):
`initialize(config)`, `recordEvent`, `recordPurchase`, `recordError`,
`recordNotification`, `recordPageView`, `identify`/`setUser`, `registerPushToken`,
`recordDeepLink`/`handleIncomingLink`, `validateReceipt`, `createDynamicLink`,
`setGdprConsent`/`setNotRequired`/`resetConsent`/`requestDataErasure`,
`setAnonymousTracking`, `flush`, `reset`, `dispose`, plus getters
`deviceId`/`isFirstLaunch`/`synchronizationState`/referrer getters/`sdkSnapshot`,
plus Apple `submitAsaToken`/`updateSkanConversionValue`/ATT `requestAuthorization`.

Events (native → Dart, `EventChannel` streams / JS callbacks): synchronization
state transitions, deep-link events (raw + resolved), initial-link resolution.

This mirrors the **KMP public surface** (`Attriax` + `tracking`/`consent`/
`deepLinks`/`synchronization`/`referrer`/`skan`) 1:1, and sdk-js exposes the same
shape on web. The wire DTOs already match (both cores were built to the same API).

### Native bindings

- **Android** (`attriax_flutter_android`): depend on `com.attriax:core-android`;
  the plugin holds one `com.attriax.sdk.Attriax` (via `AttriaxSdk.create(context,
  config)`); method-channel handlers delegate to it off the platform thread;
  register listeners → EventChannels. The existing signal code (install-referrer,
  GAID, Play Integrity) is **superseded** by the KMP core's own adapters.
- **iOS/macOS** (`attriax_flutter_ios`): embed the KMP XCFramework; the Swift
  plugin holds the KMP engine + a thin Swift shim for the Apple seams
  (ATT/IDFA/SKAN/ASA/App-Attest — the KMP `iosMain` actuals). *Mac-gated.*
- **Windows/Linux**: the KMP native lib exposes a C header (Kotlin/Native
  `-produce library`); bind via Dart FFI (or the C-API plugin). *Desktop wiring.*
- **Web** (`AttriaxWebPlugin`): load `@attriax/js`; the web plugin calls its JS
  API via `dart:js_interop`. sdk-js is the web engine.

## Phased plan (each phase ends verifiable)

0. **Architecture + branch** — this doc. ✅
1. **Expand the platform interface** — full engine command+event surface in Dart
   (abstract + `MethodChannel`/`EventChannel` impl); Dart unit tests with a fake
   platform.
2. **Android binding** — `attriax_flutter_android` embeds the KMP AAR and
   implements the interface by delegating to `Attriax`; verify on an emulator/
   device (init→/open 201, event→/batch, sync state stream) + against the dev API.
3. **Web binding** — `AttriaxWebPlugin` over `@attriax/js`; verify in a browser.
4. **Rewire the Dart facade** to route through the interface; **delete the Dart
   engine**; keep the public API identical; migrate the Dart tests to the facade.
5. **iOS/macOS** (Mac) + **Windows/Linux** (FFI) engine bindings.
6. **Parity + verification** — run the example apps (`example-rich`,
   `example-gdpr`) on each platform; device + live-API smokes; cross-check wire
   shapes against the running API.

## Risks / rules

- **Backward compatibility:** the public Dart API MUST stay identical (existing
  integrations unaffected). Any change is a breaking-change decision.
- **Reference:** the retired Dart engine is the historical behavior reference; the
  KMP core (parity-audited + P1–P7b closed) and sdk-js are the new source of
  truth. Keep the Dart engine in git history for rollback.
- **Web ≠ native parity nuance:** sdk-js has two *intentional* divergences from the
  native core (terminal-retry drop; batch-identity projectToken) — documented, not
  bugs. Flutter-web inherits sdk-js behavior on those points.
- **No push** until the user asks; child-before-root submodule discipline.
