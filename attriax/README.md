# attriax_flutter

Attriax mobile attribution SDK for Flutter.

## Overview

This is the main Flutter package for Attriax. The public `Attriax` class is a thin wrapper over an internal runtime that owns orchestration, logging, request queuing, synchronization state, and deep-link handling.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  attriax_flutter: ^0.0.2
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
    appToken: 'ax_your_app_token',
  ),
);

// Initialize the local runtime first.
await attriax.init();

// Handle startup attribution in the background.
unawaited(processAttriaxStartup(attriax));

Future<void> processAttriaxStartup(Attriax attriax) async {
  final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
  final installReferrer = await attriax.installReferrer;

  debugPrint('Install referrer: ${installReferrer?.campaign}');
  debugPrint(
    'Initial deep link: ${initialDeepLink?.resolution?.deepLink.path ?? initialDeepLink?.rawEvent?.linkPath ?? 'none'}',
  );
}

await attriax.recordPurchase(
  revenue: 99,
  currency: 'USD',
  productId: 'pro_yearly',
  transactionId: 'order_123',
  store: 'app_store',
  metadata: const <String, Object?>{'paywallVariant': 'spring_2026'},
);

final createdDynamicLink = await attriax.createDynamicLink(
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

attriax.deepLinks.stream.listen((event) async {
  final result = await event.resolve();
  final resolution = result.resolution;
  if (resolution == null) {
    return;
  }

  navigatorKey.currentState?.pushNamed(
    '/deep-link',
    arguments: resolution.deepLink,
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

Do not block your splash screen, router construction, `runApp()`, or other first-frame startup work on `installReferrer` or `deepLinks.waitForInitialDeepLink()`. Those results may wait on cached or network-backed attribution work and should normally be handled in background tasks after `init()` resolves.

If you truly need a fire-and-forget local startup path, you can still intentionally call `unawaited(attriax.init())`, but that is separate from deferred deep-link and install-referrer handling. The recommended baseline is still: await `init()`, then process startup attribution asynchronously.

The `appVersion`, `appBuildNumber`, and `appPackageName` fields let you override what the SDK reports to the API. That is useful for staged rollouts, white-label apps, and internal testing. On Flutter web, when those overrides are not set, the SDK also tries to read the build's `version.json` file so hosted deployments can report the app version automatically.

If your app consumes the incoming URL before Attriax sees it, forward the accepted
route manually with `recordDeepLink(uri: incomingUri, source: 'custom_router')`.

## Dynamic Link Creation

Use `createDynamicLink()` when your app needs a short shareable URL created at
runtime. Attriax generates the short code server-side, applies app-level
dynamic-link defaults when fields are omitted, and returns the saved link data
including the final short URL.

```dart
final result = await attriax.createDynamicLink(
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
- `data` must be a JSON object and is returned later in resolved deep-link payloads.

## Page Tracking

Use `recordPageView()` when you want page-level analytics and funnels without
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

await attriax.recordPageView(
  '/checkout',
  pageClass: 'CheckoutPage',
  previousPageName: '/cart',
  parameters: const <String, Object?>{'experiment': 'paywall_v2'},
);
```

## Host Deep Link Setup

`attriax_flutter` uses an internal Attriax deep-link bridge on Android and iOS, but the
host app still owns the platform registration files and most runner hooks.

- Android: add the intent filter to your launcher activity and keep your SHA-256 fingerprints current. The `attriax_flutter_android` plugin already injects `flutter_deeplinking_enabled=false` so Flutter's built-in handler does not compete with Attriax.
- iOS: add `<key>FlutterDeepLinkingEnabled</key><false/>` to `ios/Runner/Info.plist`, add the Associated Domains entitlement, and test on a physical device after reinstalling. This plist change still belongs to the consuming app.
- Web: the SDK reads the initial URL automatically. If your router consumes the incoming URL first, forward it with `recordDeepLink(uri: Uri.base, source: 'web_router')`. The Attriax app configuration must also allow every browser origin that will call the SDK, including local dev origins such as `http://localhost:3000`, in the dashboard setup page's Web allowed browser origins list.
- macOS, Linux, Windows: automatic deep-link capture is not bundled yet. Accept the URI in your runner or activation handler and forward it with `recordDeepLink(uri: incomingUri, source: 'desktop_router')`.

The example runner files shipped with this package include the Android and iOS
host-side setup. Desktop examples stay intentionally minimal and expect manual
forwarding when you wire a desktop protocol handler.

Because Android install referrer is the strongest attribution input for mobile installs, validate at least one Play-distributed Android build before release. iOS does not have an install-referrer equivalent, so universal-link handling and the initial app-open request become the primary checks there.

## Uninstall Tracking

Attriax accepts uninstall-tracking tokens from mobile apps so the backend can
probe whether the app instance is still reachable.

- Android: call `registerFirebaseMessagingToken(token)` after your app receives an FCM registration token and again whenever Firebase rotates that token.
- Apple platforms: if your app receives an FCM registration token, call `registerFirebaseMessagingToken(token)` there too.
- Apple platforms: if your app also receives the native APNs device token, call `registerApplePushToken(token)` to register it as a separate Apple token provider.
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
  await attriax.registerFirebaseMessagingToken(
    fcmToken,
    metadata: const <String, Object?>{'source': 'firebase_messaging'},
  );

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    final apnsToken = await messaging.getAPNSToken();
    await attriax.registerApplePushToken(
      apnsToken,
      metadata: const <String, Object?>{'source': 'firebase_messaging_apns'},
    );
  }

  messaging.onTokenRefresh.listen((token) {
    unawaited(
      attriax.registerFirebaseMessagingToken(
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
    appToken: 'ax_your_app_token',
    collectAdvertisingId: false,
    automaticCrashReportingEnabled: false,
    requestTrackingAuthorizationOnInit: false,
    trackingAuthorizationStatusTimeout: Duration(seconds: 15),
  ),
);
```

- `collectAdvertisingId` controls GAID collection on Android and IDFA collection on Apple platforms.
- When `collectAdvertisingId` is `false`, the SDK stops using ATT and advertising IDs for its own native context collection, but host apps can still call `getTrackingAuthorizationStatus()` and `requestTrackingAuthorization()` for their own consent flow.
- `automaticCrashReportingEnabled` controls automatic Flutter/native crash handlers. Manual `recordError()` calls remain available when automatic handlers are disabled.
- `requestTrackingAuthorizationOnInit` requests ATT during SDK startup when advertising ID collection is enabled, then waits for the user-driven result before iOS context collection continues.
- `trackingAuthorizationStatusTimeout` only applies when `requestTrackingAuthorizationOnInit` is `false`. During startup, the SDK polls ATT status for up to that duration so an app-managed consent flow can still call `requestTrackingAuthorization()` without being raced by SDK initialization.

To check ATT state or request ATT manually after your own consent or onboarding UI:

```dart
final currentStatus = await attriax.getTrackingAuthorizationStatus();
debugPrint('Current ATT status: $currentStatus');

final updatedStatus = await attriax.requestTrackingAuthorization();
debugPrint('Updated ATT status: $updatedStatus');
```

By default, manual ATT requests do not use a timeout. Pass `timeout:` only if your own flow needs one.

The Apple implementation package now bundles `PrivacyInfo.xcprivacy` files for its own SDK-side required-reason API usage. Those manifests only cover the plugin bundle itself.

Android apps that allow advertising ID collection must account for the AD_ID permission and Play Console Data Safety answers. iOS apps that enable tracking or IDFA collection still own the App Store privacy labels, ATT purpose string, and any app-level tracking or privacy-manifest declarations that match the configuration they actually ship.

## Deep Links

- Read `attriax.deepLinks.stream` as a broadcast stream with no buffering.
- Use `attriax.deepLinks.initialDeepLink`, `initialDeepLinkResolved`, and `waitForInitialDeepLink()` when you need synchronous initial-link state plus an awaitable completion handle.
- Read `attriax.deepLinks.latestDeepLink` when you need the most recent handled deep-link result, including deferred deep links.
- Each `AttriaxDeepLinkEvent` exposes raw link data immediately.
- Call `resolve()` on the event when you need the matched or failed backend resolution result for that specific link.

Startup handling:

```dart
final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
final path =
    initialDeepLink?.resolution?.deepLink.path ??
    initialDeepLink?.rawEvent?.linkPath;

debugPrint('Initial deep link path: ${path ?? 'none'}');
```

Stream handling:

```dart
attriax.deepLinks.stream.listen((event) async {
  final result = await event.resolve();
  final deepLink = result.resolution?.deepLink;
  if (deepLink == null) {
    return;
  }

  navigatorKey.currentState?.pushNamed('/deep-link', arguments: deepLink);
});
```

Manual forwarding for custom routers, web, or desktop runners:

```dart
await attriax.recordDeepLink(
  uri: incomingUri,
  source: 'custom_router',
);
```

## Typed Payloads

- Custom request metadata uses regular `Map<String, Object?>` values.
- For deep-link data and dynamic-link payloads, prefer primitive JSON values (`String`, `num`, `bool`, or `null`) so typed decoding stays predictable across platforms and backend versions.
- SDK transport requests and responses are concrete types internally; public payloads do not rely on `dynamic` maps.

## Examples

- Public example app: `example/`
- Public example tests: `example/test/`
- The example home screen includes a "Create sample dynamic link" action that calls the live SDK method and prints the generated short URL.

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
