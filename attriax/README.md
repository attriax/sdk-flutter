# attriax_flutter

Attriax mobile attribution SDK for Flutter.

## Overview

This is the main Flutter package for Attriax. The public `Attriax` class is a thin wrapper over an internal runtime that owns orchestration, logging, request queuing, synchronization state, and deep-link handling.

Public SDK helpers are grouped under `attriax.consent`, `attriax.tracking`, `attriax.synchronization`, `attriax.deepLinks`, `attriax.referrer`, and `attriax.skan`. The root `Attriax` entrypoint stays focused on lifecycle, reset, receipt validation, and those top-level helpers.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  attriax_flutter: ^0.4.1
```

For local workspace development inside this repository, keep using the existing path-based workspace setup instead of a hosted dependency.

## Requirements

- Dart `^3.8.0`
- Flutter `>=3.29.0`

These floors match the package `pubspec.yaml` and the current federated SDK
workspace. If your app uses an older toolchain, upgrade before evaluating this
package so plugin registration and generated-client dependencies stay aligned.

## Usage

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:attriax_flutter/attriax.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final attriax = Attriax(
  config: const AttriaxConfig(
    projectToken: 'ax_your_app_token',
    gdprEnabled: true,
  ),
);

// Initialize the local runtime first.
await attriax.init();

// Handle startup attribution in the background.
unawaited(processAttriaxStartup(attriax));

Future<void> processAttriaxStartup(Attriax attriax) async {
  final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
  final originalInstallReferrer = await attriax.referrer
      .getOriginalInstallReferrer();
  final sessionReferrer = await attriax.referrer.getSessionReferrer(
    timeout: const Duration(seconds: 5),
    safe: true,
  );

  debugPrint(
    'Original install referrer: ${originalInstallReferrer?.campaign}',
  );
  debugPrint('Session referrer: ${sessionReferrer?.uri.toString() ?? 'none'}');
  debugPrint(
    'Initial deep link: ${initialDeepLink?.uri.toString() ?? 'none'} (found: ${initialDeepLink?.found ?? false})',
  );
}

attriax.tracking.recordPurchase(
  revenue: 99,
  currency: 'USD',
  productId: 'pro_yearly',
  transactionId: 'order_123',
  store: 'app_store',
  metadata: const <String, Object?>{'paywallVariant': 'spring_2026'},
);

final createdDynamicLink = await attriax.deepLinks.createDynamicLink(
  name: 'Referral share link',
  destinationUrl: 'https://attriax.com/invite',
  group: 'referrals',
  socialPreview: const AttriaxDynamicLinkSocialPreview(
    title: 'Join me on Attriax',
    description: 'Open the app with my referral attached.',
  ),
  data: const <String, Object?>{
    'inviterId': 'user_123',
    'campaign': 'spring_referral',
  },
);

debugPrint('Share this short URL: ${createdDynamicLink.link.shortUrl}');

attriax.deepLinks.stream.listen((event) {
  if (!event.found) {
    return;
  }

  navigatorKey.currentState?.pushNamed(
    '/deep-link',
    arguments: <String, Object?>{
      'uri': event.uri.toString(),
      'data': event.data,
    },
  );
});

MaterialApp(
  navigatorKey: navigatorKey,
  navigatorObservers: [
    AttriaxNavigationObserver(attriax: attriax),
  ],
  // routes: ...
);
```

`await attriax.init()` only waits for local SDK startup work such as restoring persisted state, registering listeners, and starting the queue. It does not wait for the network-backed app-open request to finish.

The SDK still enforces app-open-first delivery behind the scenes: it sends the app-open request before any other queued SDK request, and if app-open fails, later queued requests stay deferred until an app-open request succeeds.

Do not block your splash screen, router construction, `runApp()`, or other first-frame startup work on `referrer.getOriginalInstallReferrer()` or `deepLinks.waitForInitialDeepLink()`. Those results may wait on cached or network-backed attribution work and should normally be handled in background tasks after `init()` resolves.

Use `attriax.referrer.getReinstallReferrer()` when you specifically need reinstall attribution, `getSessionReferrer()` for the deep link that opened the current session, and `getLatestDeepLinkReferrer()` for the most recent handled deep-link event.

If you truly need a fire-and-forget local startup path, you can still intentionally call `unawaited(attriax.init())`, but that is separate from deferred deep-link and install-referrer handling. The recommended baseline is still: await `init()`, then process startup attribution asynchronously.

The `appVersion`, `appBuildNumber`, and `appPackageName` fields let you override what the SDK reports to the API. That is useful for staged rollouts, white-label apps, and internal testing. On Flutter web, when those overrides are not set, the SDK also tries to read the build's `version.json` file so hosted deployments can report the app version automatically.

If your app consumes the incoming URL before Attriax sees it, forward the accepted
route manually with `attriax.deepLinks.recordDeepLink(uri: incomingUri, source: 'custom_router')`.

## GDPR Consent

`gdprEnabled` defaults to `false`. Enable it when your app wants Attriax to
wait for a GDPR decision before sending GDPR-gated tracking activity.
`anonymousTracking` defaults to `true` and keeps anonymous-capable traffic
flowing without `deviceId` while consent is unresolved. Set it to `false` when
your app wants to buffer that traffic locally until consent allows identified
delivery.

```dart
final needsLocalConsent = await attriax.consent.gdpr.needsConsent(
  localOnly: true,
);
if (needsLocalConsent) {
  // Present the app's consent UI here.
}

final needsConsent = await attriax.consent.gdpr.needsConsent();

attriax.consent.gdpr.setConsent(
  analytics: true,
  attribution: true,
  adEvents: false,
);

// Or, when the device should not be gated at all:
attriax.consent.gdpr.setNotRequired();

// Reset later if the app needs to re-ask:
attriax.consent.gdpr.reset();
```

Use `state`, `values`, and `isWaitingForConsent` to drive your privacy UI and
settings screen.

See [doc/gdpr-and-anonymous-analytics.md](doc/gdpr-and-anonymous-analytics.md) for the full GDPR and anonymous analytics behavior, including how anonymous tracking avoids device identity before consent and how to opt into local buffering instead.

## Dynamic Link Creation

Use `attriax.deepLinks.createDynamicLink()` when your app needs a short shareable URL created at
runtime. Attriax generates the short code server-side, applies app-level
dynamic-link defaults when fields are omitted, and returns the saved link data
including the final short URL.

```dart
final result = await attriax.deepLinks.createDynamicLink(
  destinationUrl: 'https://attriax.com/invite',
  group: 'creator-program',
  socialPreview: const AttriaxDynamicLinkSocialPreview(
    title: 'Creator invite',
    description: 'Open the app with the creator campaign attached.',
  ),
  data: const <String, Object?>{
    'creatorId': 'alex',
    'source': 'flutter_demo',
  },
);

debugPrint(result.link.shortUrl);
```

Notes:

- `prefix` is optional and only works when the current app plan allows custom prefixes.
- `destinationUrl` may be omitted when the app already defines a default dynamic-link destination.
- The preview image always comes from the app-level dynamic-link defaults.
- `data` must be a JSON object and is returned later in resolved deep-link payloads.

## Page Tracking

Use `attriax.tracking.recordPageView()` when you want page-level analytics and funnels without
manually naming a raw custom event. Attriax stores these under the standardized
`page_view` event name and surfaces them separately in the dashboard.

If your app relies on Flutter navigation, attach `AttriaxNavigationObserver`
to your `MaterialApp` or `CupertinoApp` to emit page views automatically for
named `PageRoute`s. If you use a router that does not populate route names,
provide a custom `routeNameResolver`.

```dart
MaterialApp(
  navigatorKey: navigatorKey,
  navigatorObservers: [
    AttriaxNavigationObserver(attriax: attriax),
  ],
);

attriax.tracking.recordPageView(
  '/checkout',
  pageClass: 'CheckoutPage',
  previousPageName: '/cart',
  parameters: const <String, Object?>{'experiment': 'paywall_v2'},
);
```

## Analytics Vocabulary

The package exports `AttriaxAnalyticsEventKeys` and
`AttriaxAnalyticsParamKeys` so your app, dashboard funnels, and SKAN schema can
share the same event vocabulary.

Use the predefined event keys for the most common conversion milestones:

- account lifecycle: `sign_up`, `login`
- onboarding and game progression: `tutorial_begin`, `tutorial_complete`, `level_start`, `level_complete`, `level_up`
- checkout and revenue: `add_payment_info`, `add_to_cart`, `checkout_started`, `purchase`, `refund`, `subscription_started`, `subscription_renewed`, `trial_started`
- ads and navigation: `ad_*` events plus `page_view`

Use the predefined parameter keys when those events need consistent payloads.
The most common ones are `revenue`, `currency`, `productId`, `transactionId`,
`paymentType`, `method`, `level`, `value`, `pageName`, `adPlacement`, and
`source`.

```dart
attriax.tracking.recordEvent(
  AttriaxAnalyticsEventKeys.addPaymentInfo,
  eventData: const <String, Object?>{
    AttriaxAnalyticsParamKeys.paymentType: 'apple_pay',
    AttriaxAnalyticsParamKeys.value: 'annual_paywall',
  },
);

attriax.tracking.recordEvent(
  AttriaxAnalyticsEventKeys.tutorialBegin,
  eventData: const <String, Object?>{
    AttriaxAnalyticsParamKeys.source: 'first_session',
  },
);
```

These constants are intentionally curated rather than exhaustive. If your app
needs a custom event name, you can still send it with
`attriax.tracking.recordEvent(...)`; use the shared constants whenever you want
a stable, SDK-documented conversion event name.

## Ad Events

Use the standardized ad lifecycle methods when you want ad delivery,
engagement, failures, rewards, and paid callbacks to show up in the same
analytics vocabulary across SDKs.

```dart
attriax.tracking.recordAdEvent(
  AttriaxAdEventType.load,
  adNetwork: 'admob',
  adUnitId: rewardedAdUnitId,
  adPlacement: 'level_complete',
  adFormat: 'rewarded',
);

attriax.tracking.recordAdEvent(
  AttriaxAdEventType.show,
  adNetwork: 'admob',
  adUnitId: rewardedAdUnitId,
  adPlacement: 'level_complete',
  adFormat: 'rewarded',
);

attriax.tracking.recordAdEvent(
  AttriaxAdEventType.impression,
  adNetwork: 'admob',
  adUnitId: rewardedAdUnitId,
  adPlacement: 'level_complete',
  adFormat: 'rewarded',
);

attriax.tracking.recordAdEvent(
  AttriaxAdEventType.reward,
  adNetwork: 'admob',
  adUnitId: rewardedAdUnitId,
  adPlacement: 'level_complete',
  adFormat: 'rewarded',
  rewardType: 'coins',
  rewardAmount: 50,
);

attriax.tracking.recordAdRevenue(
  revenue: 125000,
  currency: 'USD',
  revenueInMicros: true,
  adNetwork: 'admob',
  adPlacement: 'level_complete',
  adFormat: 'rewarded',
  adType: 'paid_event',
);
```

When an ad SDK exposes failures, clicks, dismissals, or mediation metadata,
send them through `attriax.tracking.recordAdEvent(...)` with the matching
`AttriaxAdEventType`, `failureReason`, and `metadata` so the ad-events
analytics page can group the callbacks cleanly.

## Push Notification Attribution

Attriax never sends pushes itself. Your app keeps its own push stack (Firebase
Messaging, native APNs, etc.) and forwards notification lifecycle events to
Attriax from your existing handlers. This manual-forwarding model is intentional:
it lets Attriax attribution coexist with whatever push tooling you already ship,
and it means you decide exactly which payload fields (including any Attriax
`linkId`/`campaignId`) get threaded through.

Use `attriax.tracking.recordNotification(...)` with an explicit
`AttriaxNotificationEventType`, or one of the three convenience wrappers:

- `recordNotificationReceived(...)` — the push was **delivered/displayed**.
  Measures deliverability and reach.
- `recordNotificationOpened(...)` — the user **tapped** the push. This is the
  **high-value signal**: it powers re-engagement attribution and ties any
  downstream conversions or revenue back to the campaign.
- `recordNotificationDismissed(...)` — the user **swiped the push away** without
  opening it. A best-effort negative signal (see the caveat below).

`type` is one of `received | opened | dismissed`. `source` is one of
`fcm | apns | other`; if you omit it, the SDK infers it from the payload
(an `aps` key → `apns`; `google.*` / `gcm.*` keys → `fcm`). Pass the raw FCM/APNs
data map as `payload` and it is preserved in the notification metadata. Thread
through any Attriax `linkId`/`campaignId` embedded in the payload so opens and
their downstream events attribute back to the originating link/campaign.

These calls route through the same offline-persisted, batched, retried queue as
`recordEvent`, and honor the same app-open-first and consent semantics.

### On tap — the opened signal (FCM/APNs tap handler)

Call `recordNotificationOpened` from wherever your app already handles a
notification tap. With Firebase Messaging that is
`FirebaseMessaging.onMessageOpenedApp` (background → foreground) plus
`getInitialMessage()` (cold start from a tap):

```dart
import 'package:attriax_flutter/attriax.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void recordPushOpen(Attriax attriax, RemoteMessage message) {
  attriax.tracking.recordNotificationOpened(
    notificationId: message.messageId ?? 'unknown',
    // Thread the Attriax references your campaign embedded in the data payload.
    linkId: message.data['ax_link_id'] as String?,
    campaignId: message.data['ax_campaign_id'] as String?,
    title: message.notification?.title,
    // `source` is omitted on purpose — the SDK infers fcm/apns from the payload.
    payload: message.data,
  );
}

Future<void> wirePushOpenHandlers(Attriax attriax) async {
  // App resumed from background by tapping the notification.
  FirebaseMessaging.onMessageOpenedApp.listen(
    (message) => recordPushOpen(attriax, message),
  );

  // App launched cold from a notification tap.
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    recordPushOpen(attriax, initialMessage);
  }
}
```

### On receipt — the received signal

Record receipt when the push arrives while your app can observe it — for
foreground messages via `FirebaseMessaging.onMessage`, or from your
data-message handler:

```dart
FirebaseMessaging.onMessage.listen((message) {
  attriax.tracking.recordNotificationReceived(
    notificationId: message.messageId ?? 'unknown',
    linkId: message.data['ax_link_id'] as String?,
    campaignId: message.data['ax_campaign_id'] as String?,
    title: message.notification?.title,
    payload: message.data,
  );

  // ...then render your own foreground notification UI if desired.
});
```

### On dismissal — best-effort, with caveats

Dismissal is only reliably observable when **your app builds the notification
itself** so it can attach a dismiss callback. It is **not** available for
OS-displayed notification messages (where the system draws the alert), and it is
**not** delivered while the app is terminated.

- **Android:** show the notification yourself from a **data** message (e.g. via
  `flutter_local_notifications`) and attach a `deleteIntent` / delete callback;
  call `recordNotificationDismissed` from that callback.
- **iOS:** register a notification **category with a custom dismiss action** and
  forward that action to `recordNotificationDismissed`.

```dart
// Called from your own deleteIntent / dismiss-action callback.
void recordPushDismiss(
  Attriax attriax, {
  required String notificationId,
  String? linkId,
  String? campaignId,
  String? title,
  Map<String, Object?>? payload,
}) {
  attriax.tracking.recordNotificationDismissed(
    notificationId: notificationId,
    linkId: linkId,
    campaignId: campaignId,
    title: title,
    source: AttriaxNotificationEventSource.fcm, // pass explicitly if no payload
    payload: payload,
  );
}
```

Treat dismissals as a best-effort negative signal rather than a complete count.
Prioritize wiring `opened` first — it is the signal that drives re-engagement
attribution and downstream conversion/revenue ties.

## Host Deep Link Setup

`attriax_flutter` uses an internal Attriax deep-link bridge on Android and iOS, but the
host app still owns the platform registration files and most runner hooks.

- Android: add the intent filter to your launcher activity and keep your SHA-256 fingerprints current. The `attriax_flutter_android` plugin already injects `flutter_deeplinking_enabled=false` so Flutter's built-in handler does not compete with Attriax.
- iOS: add `<key>FlutterDeepLinkingEnabled</key><false/>` to `ios/Runner/Info.plist`, add the Associated Domains entitlement, and test on a physical device after reinstalling. If your app requests ATT through Attriax or its own consent flow, the same plist must also include `NSUserTrackingUsageDescription` before `requestTrackingAuthorizationOnInit` or `consent.att.requestTrackingAuthorization()` runs. These plist changes still belong to the consuming app.
- Web: the SDK reads the initial URL automatically. If your router consumes the incoming URL first, forward it with `attriax.deepLinks.recordDeepLink(uri: Uri.base, source: 'web_router')`. The Attriax app configuration must also allow every browser origin that will call the SDK, including local dev origins such as `http://localhost:3000`, in the dashboard setup page's Web allowed browser origins list.
- macOS, Linux, Windows: automatic deep-link capture is not bundled yet. Accept the URI in your runner or activation handler and forward it with `attriax.deepLinks.recordDeepLink(uri: incomingUri, source: 'desktop_router')`.

The example runner files shipped with this package include the Android and iOS
host-side setup. Desktop examples stay intentionally minimal and expect manual
forwarding when you wire a desktop protocol handler.

Because Android install referrer is the strongest attribution input for mobile installs, validate at least one Play-distributed Android build before release. iOS does not have an install-referrer equivalent, so universal-link handling and the initial app-open request become the primary checks there.

## SKAdNetwork Developer-Copy Setup

SKAdNetwork developer-copy reporting is separate from Attriax deep-link setup.
There are two independent pieces:

- Your app usually lets Attriax download the SKAN schema from the dashboard during app open.
- Apple sends developer-copy install-validation postbacks to the URL declared in the consuming app's `Info.plist`.

Use local `AttriaxConfig.skan` only when you want to disable SDK-side conversion updates in app code:

```dart
final attriax = Attriax(
  config: const AttriaxConfig(
    projectToken: 'ax_your_app_token',
    skan: AttriaxSkanConfig(enabled: false),
  ),
);
```

On iOS, add the hardcoded Attriax developer-copy host to the advertised app's
`ios/Runner/Info.plist`:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://skan.attriax.com</string>

<key>SKAdNetworkPostbackURLList</key>
<array>
  <string>https://skan.attriax.com</string>
</array>
```

Keep the configured value pathless. Apple and newer toolchains derive the
well-known callback path automatically. Apple documents that
`NSAdvertisingAttributionReportEndpoint` uses only the registrable domain and
ignores subdomains, so do not point these settings at an app-specific host such
as `myapp.attriax.com`.

Attriax accepts developer-copy callbacks at:

- `https://skan.attriax.com/.well-known/skadnetwork/report-attribution/`
- `https://attriax.com/.well-known/skadnetwork/report-attribution/`

Dashboard SKAN surfaces are now the normal source of runtime SKAN rules. The SDK
downloads the app schema during app open, while local `AttriaxConfig.skan`
configuration is reserved for explicit app-code opt-out cases such as disabling
local SKAN updates in a particular build.

Save the numeric iOS App Store ID in the Attriax dashboard so Attriax can map
incoming postbacks back to the app.

## Uninstall Tracking

Attriax accepts uninstall-tracking tokens from mobile apps so the backend can
probe whether the app instance is still reachable.

- Android: call `tracking.registerFirebaseMessagingToken(token)` after your app receives an FCM registration token and again whenever Firebase rotates that token.
- Apple platforms: if your app receives an FCM registration token, call `tracking.registerFirebaseMessagingToken(token)` there too.
- Apple platforms: if your app also receives the native APNs device token, call `tracking.registerApplePushToken(token)` to register it as a separate Apple token provider.
- Pass `null` or whitespace to either method when you need to clear the currently registered token for that provider.

Attriax probes FCM registrations through Firebase Admin. When you configure the
APNs auth key in the Attriax dashboard, Attriax can also probe native APNs
tokens directly for Apple-platform uninstall detection.

```dart
import 'dart:async';
import 'package:attriax_flutter/attriax.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future<void> syncPushTokensWithAttriax(Attriax attriax) async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  final fcmToken = await messaging.getToken();
  await attriax.tracking.registerFirebaseMessagingToken(
    fcmToken,
    metadata: const <String, Object?>{'source': 'firebase_messaging'},
  );

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    final apnsToken = await messaging.getAPNSToken();
    await attriax.tracking.registerApplePushToken(
      apnsToken,
      metadata: const <String, Object?>{'source': 'firebase_messaging_apns'},
    );
  }

  messaging.onTokenRefresh.listen((token) {
    unawaited(
      attriax.tracking.registerFirebaseMessagingToken(
        token,
        metadata: const <String, Object?>{'source': 'firebase_messaging_refresh'},
      ),
    );
  });
}
```

## Synchronization

Most apps do not need to surface synchronization state in normal product UI.
Treat it as an optional diagnostics hook for QA, support flows, offline-aware
surfaces, or developer tooling.

- Use `attriax.synchronization.isSynchronized` when you only need a single readiness boolean.
- Use `attriax.synchronization.state` or `attriax.synchronization.states` when you need to distinguish between initializing, actively syncing, deferred queue work, offline, failed, disabled, and fully synchronized states.

## Local Storage And Reset

The SDK persists a small amount of local state so it can survive process restarts:

- stable Attriax device identity and device-id source
- enabled and events-enabled runtime flags
- first-launch marker
- queued requests and queue diagnostics, including pending crash/error payloads
- current session snapshot
- cached install-referrer details

Use `await attriax.reset()` when the host app needs to clear SDK-owned local
state for privacy tooling, logout cleanup, QA reset flows, or support recovery.
After `reset()` completes, call `await attriax.init()` again before reusing the
same instance.

`reset()` clears SDK-owned local storage only. It does not delete any server-side
analytics or attribution data that has already been delivered to Attriax.

## Logging

- Debug builds use verbose SDK logging by default.
- Non-debug builds keep logging to warning and error paths.
- Set `enableDebugLogs` in `AttriaxConfig` when you need to override debug verbosity.

## Privacy Controls

Attriax collects only the platform context needed for attribution and analytics, but the host app owns its store disclosures and consent flow. Configure these options before `init()`:

```dart
final attriax = Attriax(
  config: const AttriaxConfig(
    projectToken: 'ax_your_app_token',
    collectAdvertisingId: false,
    automaticCrashReportingEnabled: false,
    anonymousTracking: true,
    requestTrackingAuthorizationOnInit: false,
    trackingAuthorizationStatusTimeout: Duration(seconds: 15),
  ),
);
```

- `collectAdvertisingId` controls GAID collection on Android and IDFA collection on Apple platforms.
- When `collectAdvertisingId` is `false`, the SDK stops using ATT and advertising IDs for its own native context collection, but host apps can still call `consent.att.getTrackingAuthorizationStatus()` and `consent.att.requestTrackingAuthorization()` for their own consent flow.
- `automaticCrashReportingEnabled` controls automatic Flutter/native crash handlers. Manual `tracking.recordError()` calls remain available when automatic handlers are disabled.
- `anonymousTracking` keeps anonymous-capable GDPR traffic flowing without device identity while consent is unresolved. Disable it if your app prefers to buffer that activity locally until consent allows identified delivery.
- `requestTrackingAuthorizationOnInit` requests ATT during SDK startup when advertising ID collection is enabled, then waits for the user-driven result before iOS context collection continues. Add `NSUserTrackingUsageDescription` to `ios/Runner/Info.plist` before enabling this on iOS.
- `trackingAuthorizationStatusTimeout` only applies when `requestTrackingAuthorizationOnInit` is `false`. During startup, the SDK polls ATT status for up to that duration so an app-managed consent flow can still call `consent.att.requestTrackingAuthorization()` without being raced by SDK initialization.

To check ATT state or request ATT manually after your own consent or onboarding UI:

Add `NSUserTrackingUsageDescription` to `ios/Runner/Info.plist` before shipping or testing the manual ATT prompt.

```dart
final currentStatus = await attriax.consent.att.getTrackingAuthorizationStatus();
debugPrint('Current ATT status: $currentStatus');

final updatedStatus = await attriax.consent.att.requestTrackingAuthorization();
debugPrint('Updated ATT status: $updatedStatus');
```

By default, manual ATT requests do not use a timeout. Pass `timeout:` only if your own flow needs one.

The Apple implementation package now bundles `PrivacyInfo.xcprivacy` files for its own SDK-side required-reason API usage and SDK-owned data collection declarations. Today those manifests cover `Device ID` on iOS and macOS plus `Crash Data` on iOS.

Android apps that allow advertising ID collection must account for the AD_ID permission and Play Console Data Safety answers. iOS apps that enable tracking or IDFA collection still own the App Store privacy labels, ATT purpose string, and any app-level tracking domains or privacy-manifest declarations that match the configuration they actually ship.

## Device Attestation

`attestationEnabled` defaults to `false`. Existing integrations are unaffected: when it is `false`, the SDK never requests an attestation nonce and never attaches an attestation envelope to the app-open/init request.

Attestation is opt-in and defensive — enabling it never blocks or fails `init()`. When enabled, the SDK fetches a single-use nonce, asks the configured provider for a Play Integrity (Android) or App Attest (iOS) token, and attaches the resulting envelope. Server-side verification is itself inert unless the project opts into `requireAttestation` in the dashboard, so an unverified project sees no change.

```dart
final attriax = Attriax(
  config: AttriaxConfig(
    projectToken: 'ax_your_app_token',
    attestationEnabled: true,
    attestationProvider: AttriaxPlatformAttestationProvider(
      currentPlatform: () => AttriaxPlatformType.android,
    ),
  ),
);
```

- When `attestationEnabled` is `true` but `attestationProvider` is `null`, the SDK uses a no-op provider (no envelope is sent).
- A failed challenge fetch or a provider that returns no token sends the init request with no envelope; attestation never throws into `init()`.
- The native Play Integrity / App Attest token acquisition is a platform seam that ships as a no-op stub today, so the SDK degrades to "unattested" until the native providers are wired for your app.

## Deep Links

- Read `attriax.deepLinks.stream` as a broadcast stream with no buffering.
- Use `attriax.deepLinks.initialDeepLink`, `initialDeepLinkResolved`, and `waitForInitialDeepLink()` when you need synchronous initial-link state plus an awaitable completion handle.
- Read `attriax.deepLinks.latestDeepLink` when you need the most recent handled deep-link event, including deferred deep links.
- Each `AttriaxDeepLinkEvent` is already resolved and exposes `uri`, `clickedAt`, `consumedAt`, `trigger`, `isAttriaxSubDomain`, `found`, and any matched `data` immediately.
- Use `attriax.deepLinks.rawStream` together with `waitResolution(rawEvent)` only when you specifically need to observe the pre-resolution raw input and then await its resolved event.

Startup handling:

```dart
final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
final path = initialDeepLink?.uri.path;

debugPrint(
  'Initial deep link path: ${path ?? 'none'} (found: ${initialDeepLink?.found ?? false})',
);
```

Stream handling:

```dart
attriax.deepLinks.stream.listen((event) {
  if (!event.found) {
    return;
  }

  navigatorKey.currentState?.pushNamed(
    '/deep-link',
    arguments: <String, Object?>{
      'uri': event.uri.toString(),
      'data': event.data,
    },
  );
});
```

Manual forwarding for custom routers, web, or desktop runners:

```dart
await attriax.deepLinks.recordDeepLink(
  uri: incomingUri,
  source: 'custom_router',
);
```

## Typed Payloads

- Custom request metadata uses regular `Map<String, Object?>` values.
- For deep-link data and dynamic-link payloads, prefer primitive JSON values (`String`, `num`, `bool`, or `null`) so typed decoding stays predictable across platforms and backend versions.
- SDK transport requests and responses are concrete types internally; public payloads do not rely on `dynamic` maps.

## Examples

- Package example app: `example/`
- Package example tests: `example/test/`
- This publishable package now keeps the shipped example focused on minimal integration. Richer public demo flows live elsewhere in the repository, and internal QA flows stay in the non-public internal tester app.

## Platform Support

- **Android** ≥ Android 5.0 (API Level 21) with built-in Attriax deep-link bridge
- **iOS** ≥ iOS 13.0 with built-in Attriax deep-link bridge
- **Web** with initial-URL deep-link support
- **Windows** with manual forwarding
- **macOS** with manual forwarding
- **Linux** with manual forwarding

## Architecture

This package provides the public API and uses the platform interface only for native-only data.

- Depends on: `attriax_flutter_platform_interface`
- Implements native collectors via `attriax_flutter_android` and `attriax_flutter_ios`
- Keeps the public `Attriax` API as a wrapper over internal runtime, queue, logger, and typed transport components

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
