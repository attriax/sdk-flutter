# attriax

Attriax mobile attribution SDK for Flutter.

## Overview

This is the main Flutter package for Attriax. The public `Attriax` class is a thin wrapper over an internal runtime that owns orchestration, logging, request queuing, synchronization state, and deep-link handling.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  attriax: ^1.0.0
```

For local workspace development inside this repository, keep using the existing path-based workspace setup instead of a hosted dependency.

## Usage

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:attriax/attriax.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final attriax = Attriax(
  config: const AttriaxConfig(
    appToken: 'ax_your_app_token',
    appVersion: '2026.04.0',
    appBuildNumber: '1042',
  ),
);

// Recommended: await startup initialization.
await attriax.init();

// Process install-referrer and startup deep-link results in the background.
unawaited(processAttriaxStartup(attriax));

Future<void> processAttriaxStartup(Attriax attriax) async {
  final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
  final installReferrer = await attriax.installReferrer;

  debugPrint('Install referrer: ${installReferrer?.campaign}');
  debugPrint(
    'Initial deep link: ${initialDeepLink?.resolution?.deepLink.path ?? initialDeepLink?.rawEvent?.linkPath ?? 'none'}',
  );
}

await attriax.recordEvent(
  'purchase_completed',
  eventData: const <String, Object?>{'value': 99, 'currency': 'USD'},
);

await attriax.recordPageView(
  '/checkout',
  pageClass: 'CheckoutPage',
  previousPageName: '/cart',
  parameters: const <String, Object?>{'experiment': 'paywall_v2'},
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

The `appVersion`, `appBuildNumber`, and `appPackageName` fields let you override what the SDK reports to the API. That is useful for staged rollouts, white-label apps, and internal testing.

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

## Host Deep Link Setup

`attriax` uses an internal Attriax deep-link bridge on Android and iOS, but the
host app still owns the platform registration files and most runner hooks.

- Android: add the intent filter to your launcher activity and keep your SHA-256 fingerprints current. The `attriax_android` plugin already injects `flutter_deeplinking_enabled=false` so Flutter's built-in handler does not compete with Attriax.
- iOS: add `<key>FlutterDeepLinkingEnabled</key><false/>` to `ios/Runner/Info.plist`, add the Associated Domains entitlement, and test on a physical device after reinstalling. This plist change still belongs to the consuming app.
- Web: the SDK reads the initial URL automatically. If your router consumes the incoming URL first, forward it with `recordDeepLink(uri: Uri.base, source: 'web_router')`.
- macOS, Linux, Windows: automatic deep-link capture is not bundled yet. Accept the URI in your runner or activation handler and forward it with `recordDeepLink(uri: incomingUri, source: 'desktop_router')`.

The example runner files shipped with this package include the Android and iOS
host-side setup. Desktop examples stay intentionally minimal and expect manual
forwarding when you wire a desktop protocol handler.

Because Android install referrer is the strongest attribution input for mobile installs, validate at least one Play-distributed Android build before release. iOS does not have an install-referrer equivalent, so universal-link handling and the initial app-open request become the primary checks there.

## Synchronization

- Use `attriax.synchronization.isSynchronized` when you only need a single readiness boolean.
- Use `attriax.synchronization.state` or `attriax.synchronization.states` when your UI should distinguish between initializing, syncing, offline, failed, disabled, and fully synchronized states.

## Logging

- Debug builds use verbose SDK logging by default.
- Non-debug builds keep logging to warning and error paths.
- Set `enableDebugLogs` in `AttriaxConfig` when you need to override debug verbosity.

## Deep Links

- Read `attriax.deepLinks.stream` as a broadcast stream with no buffering.
- Use `attriax.deepLinks.initialDeepLink`, `initialDeepLinkResolved`, and `waitForInitialDeepLink()` when you need synchronous initial-link state plus an awaitable completion handle.
- Read `attriax.deepLinks.latestDeepLink` when you need the most recent handled deep-link result, including deferred deep links.
- Each `AttriaxDeepLinkEvent` exposes raw link data immediately.
- Call `resolve()` on the event when you need the matched or failed backend resolution result for that specific link.

## Typed Payloads

- Custom request metadata uses regular `Map<String, Object?>` values.
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

- Depends on: `attriax_platform_interface`
- Implements native collectors via `attriax_android` and `attriax_ios`
- Keeps the public `Attriax` API as a wrapper over internal runtime, queue, logger, and typed transport components

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
