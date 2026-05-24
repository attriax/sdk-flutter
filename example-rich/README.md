# attriax_flutter_rich_example

Rich public demo app for the Attriax Flutter SDK.

This example now follows the recommended integration shape for real apps:

- one global Attriax instance
- awaited `init()` in `main()`
- app token configured directly in source
- a small custom GDPR prompt on the home page when consent is pending
- page-based UI for diagnostics and demo flows instead of a setup wizard

## Configuration

Set the example app token in `lib/example_app_configuration.dart`.

The example bootstrap intentionally enables `gdprEnabled: true` and keeps
`gdprAutoDetect: true` so the Controls page can demonstrate pending,
not-required, and granted consent states without changing source files between
runs.

The example intentionally does not store the token in local device storage and
does not expose a UI to edit it at runtime. Update the source file when you
want to point the example at a different Attriax app.

The same file also defines the default deep-link host used by the demo:

- host: `example-test.attriax.com`
- path: `example/deep-link-success`

## What The App Shows

### Home

- current SDK synchronization state
- first-launch and device identity details
- latest install referrer details
- latest deep-link and token-registration summaries
- direct navigation to each focused demo page
- direct Accept analytics / Reject analytics actions when GDPR consent is needed

### Deep Links

- current initial and latest deep-link state
- create, copy, and share a demo Attriax link
- manual deep-link recording helper for desktop/manual routing flows
- dedicated result route that shows the incoming event and resolved payload
- Android app-link verification status for `example-test.attriax.com`
- button to open Android's “Open by default” settings when verification or user approval is missing

### Token Registration

- live Firebase Messaging permission and token status
- FCM token registration into Attriax when Firebase is configured
- APNs token status on Apple platforms when available
- diagnostic setup hints instead of fake manual send / clear buttons

### Events

- custom events
- page-view tracking
- ad lifecycle and ad-revenue examples
- purchase and refund examples
- receipt validation example

### Controls

- SDK enabled toggle
- custom-events enabled toggle
- GDPR state, local and remote consent checks, and explicit consent actions
- demo user identity actions
- demo user-property actions
- reset flow for the running example app

### Mini Game

- small Flutter-only reflex game
- start, milestone, and finish gameplay events sent through Attriax

## Native Host Setup Included

The example host apps are wired for the demo deep-link domain:

- Android manifest host: `example-test.attriax.com`
- Android method channel: app-link verification status + open-settings action
- iOS associated domains entitlement: `applinks:example-test.attriax.com`

Important caveats still apply:

- Android verification only succeeds when the domain serves a valid `assetlinks.json` for the example app signing identity.
- iOS universal links only work when the domain serves a valid Apple App Site Association file and the app is signed with the entitlement in place.
- The in-app domain status surface is Android-specific. iOS still relies on system behavior rather than an exposed verification API.

## Firebase Messaging Caveat

The token-registration page expects real Firebase app setup.

Add the normal platform configuration files before expecting live push-token
registration to succeed:

- Android: `google-services.json`
- Apple platforms: `GoogleService-Info.plist`

If Firebase is not configured, the example shows a diagnostic status and setup
hint instead of pretending token registration succeeded.

## Web Note

When running the example on web, allow the serving origin in the Attriax app
configuration. For local development, that usually means allowing the Flutter
dev-server origin you are using, for example `http://localhost:3000`.

## Run It

```bash
cd example-rich
flutter run
```

## Validate It

```bash
cd example-rich
flutter analyze .
flutter test test/main_test.dart
```

If you intentionally want to demo a fire-and-forget startup path instead, make
that change explicitly in `main()`; the example defaults to awaited
initialization on purpose.