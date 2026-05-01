# attriax_example

Minimal public example app for the Attriax Flutter SDK.

## What It Shows

- constructing `Attriax` with a `AttriaxConfig`
- awaited `init()` as the recommended startup path, plus optional `waitForAppOpenTracking()`
- synchronization state with a clear ready / not-ready signal via `attriax.synchronization`
- listening to the unified `deepLinks` stream and routing matched resolutions into app screens
- reading `deepLinks.initialDeepLink`, `deepLinks.initialDeepLinkResolved`, and `deepLinks.latestDeepLink`
- runtime SDK enable and custom-event enable toggles
- manual deep-link resolution reporting

## Run It

```bash
cd attriax/example
flutter run
flutter test
```

Before expecting successful synchronization, replace the placeholder app token
in `lib/main.dart` with a real Attriax app token.

The example runner files include the Android and iOS host-side deep-link setup
used by Attriax. Desktop platforms are still manual: if your app accepts a URL
on macOS, Linux, or Windows, forward it into the SDK with
`recordDeepLinkConversion(...)`.

The widget tests in `test/main_test.dart` cover the two most important example flows: waiting for the app-open result and routing a matched deep link into the demo screens.

If you need to validate a non-blocking startup flow, switch the example app's `main()` to use `unawaited(attriax.init())` intentionally.