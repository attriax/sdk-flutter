# attriax_flutter_example

Minimal public example app for the Attriax Flutter SDK.

## What It Shows

- constructing `Attriax` with a `AttriaxConfig`
- a first-run setup screen that stores the app token and optional API base URL locally
- awaited `init()` as the recommended startup path, plus background startup attribution via `installReferrer` and `deepLinks.waitForInitialDeepLink()`
- synchronization state with a clear ready / not-ready signal via `attriax.synchronization`
- listening to the unified `deepLinks` stream and routing matched resolutions into app screens
- reading `deepLinks.initialDeepLink`, `deepLinks.initialDeepLinkResolved`, and `deepLinks.latestDeepLink`
- runtime SDK enable and custom-event enable toggles
- manual examples for sending Firebase and APNs uninstall tokens into Attriax
- manual deep-link resolution reporting

## Run It

```bash
cd attriax/example
flutter run
flutter test
```

On first launch, enter a real Attriax app token in the setup screen. The
example stores that token locally on the device so later runs do not require
dart-defines or source edits. You can also override the API base URL there
when testing against a non-production backend.

When you run the example on web, the Attriax app configuration must allow the
browser origin you are serving from. Add each dev or production origin in the
Attriax dashboard setup page under the Web section's allowed browser origins,
for example `http://localhost:3000` for local Flutter web runs. Without that,
browser requests will fail CORS even when the app token itself is valid.

The example runner files include the Android and iOS host-side deep-link setup
used by Attriax. Desktop platforms are still manual: if your app accepts a URL
on macOS, Linux, or Windows, forward it into the SDK with
`recordDeepLink(...)`.

The home screen also includes an uninstall-token demo card. It does not fetch
real Firebase or APNs tokens itself; instead it shows the exact Attriax SDK
methods to call and lets you manually send placeholder values so you can verify
the request flow without adding Firebase setup to the public example.

The widget tests in `test/main_test.dart` cover the first-run setup shell plus
the two most important demo flows: loading startup attribution state and
routing a matched deep link into the demo screens.

If you need to validate a non-blocking startup flow, switch the example app's `main()` to use `unawaited(attriax.init())` intentionally.