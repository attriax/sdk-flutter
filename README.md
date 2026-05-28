# [Attriax](https://attriax.com) Flutter SDK

`sdk-flutter/` is the Flutter SDK workspace for Attriax. Most production apps
should depend on `attriax_flutter`, which is the main public package and the
reference runtime for shared SDK behavior across Flutter, web, React, and Unity.

If you want the package-level guide, examples, and API-focused usage notes,
start with [attriax/README.md](attriax/README.md).

## What To Install

For real app integrations, use `attriax_flutter`:

```bash
flutter pub add attriax_flutter
```

This workspace also contains the federated platform packages, the shared
platform interface, and the generated internal API client, but most apps should
not import those packages directly.

## Quick Start

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:attriax_flutter/attriax.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final attriax = Attriax(
	config: const AttriaxConfig(
		projectToken: 'ax_your_app_token',
	),
);

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await attriax.init();
	unawaited(processAttriaxStartup(attriax));
	runApp(const MyApp());
}

Future<void> processAttriaxStartup(Attriax attriax) async {
	final initialDeepLink = await attriax.deepLinks.waitForInitialDeepLink();
	debugPrint(
		'${initialDeepLink?.uri.toString() ?? 'no deep link'} (found: ${initialDeepLink?.found ?? false})',
	);
}

MaterialApp(
	navigatorKey: navigatorKey,
	navigatorObservers: [
		AttriaxNavigationObserver(attriax: attriax),
	],
);

await attriax.tracking.recordPageView(
	'/checkout',
	pageClass: 'CheckoutPage',
	previousPageName: '/cart',
);

await attriax.tracking.recordPurchase(
	revenue: 9.99,
	currency: 'USD',
	productId: 'pro_monthly',
	transactionId: 'order_123',
	store: 'app_store',
);

await attriax.tracking.recordAdEvent(
	AttriaxAdEventType.impression,
	adNetwork: 'admob',
	adPlacement: 'level_complete',
	adFormat: 'rewarded',
);
```

## What The Flutter SDK Covers

- App-open attribution, deep-link resolution, and deferred deep-link handling.
- Automatic or manual page tracking through `AttriaxNavigationObserver` and `tracking.recordPageView(...)`.
- Custom events, crash/error reporting, purchase revenue, ad revenue, and standardized ad lifecycle events.
- Install-referrer access on Android when it is available.
- Firebase and APNs token registration for uninstall-tracking flows.
- Dynamic-link creation from the app runtime.
- GDPR-aware consent helpers under `attriax.consent.gdpr`, including immediate anonymous-capable dispatch while consent is `unknown` or `pending` and anonymous analytics-capable delivery for denied analytics paths.

## Platform Notes

- Android and iOS are the primary mobile targets and have the strongest runtime support.
- Web resolves the initial URL automatically in Dart.
- Windows, macOS, and Linux can forward deep links into Attriax, but desktop URI handling remains more manual.
- Host apps still own platform files such as Android App Links, iOS Associated Domains, `FlutterDeepLinkingEnabled`, and ATT messaging text like `NSUserTrackingUsageDescription`.

## More Documentation

- [attriax/README.md](attriax/README.md) — main package usage guide and API-oriented integration notes.
- [attriax/doc/gdpr-and-anonymous-analytics.md](attriax/doc/gdpr-and-anonymous-analytics.md) — package-local GDPR consent and anonymous analytics behavior.
- [CONTRIBUTING.md](CONTRIBUTING.md) — contributor workflow for developing inside this workspace.
- [PUBLISHING.md](PUBLISHING.md) — package release order, dry-run checks, and publishing steps.
- [SDK_CLIENT_GENERATION.md](SDK_CLIENT_GENERATION.md) — generated client workflow and contract regeneration details.

Development commands, example-app workflows, internal tester notes, and other
workspace-maintainer guidance now live in the root [../AGENTS.md](../AGENTS.md)
file instead of this consumer-facing README.

## License

This repository and the publishable Flutter SDK packages ship under Apache-2.0.
Each published package also includes its own `LICENSE` file so the license is
preserved in the pub.dev archive.

