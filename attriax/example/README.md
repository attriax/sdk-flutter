# attriax_flutter_example

Minimal integration example for the Attriax Flutter SDK.

This package example shows the smallest recommended integration shape for a real app:

- one global Attriax instance
- awaited `init()` in `main()`
- app token configured directly in source
- `AttriaxNavigationObserver` attached to `MaterialApp`
- one sample event button
- deep-link state surfaced in the UI

## Configuration

Set the example app token in `lib/example_app_configuration.dart`.

The example intentionally keeps configuration in source so the entrypoint stays
close to the README usage snippet. Update the source file when you want to point
the example at a different Attriax app.

The same file also defines the default deep-link host used by the sample UI:

- host: `example-test.attriax.com`
- path: `example/deep-link-success`

## What The App Shows

- current SDK synchronization state
- the configured app token in masked form
- the latest received deep link, if any
- a sample event button that records `integration_checkout_started`
- a second route so the example has a real navigation observer hookup

## Richer Public Demo

The repository also keeps a richer public demo app in `sdk-flutter/example-rich/`.
Use that app when you want broader deep-link, push-token, SKAN, and demo-flow
coverage.

`flutter-internal-tester/` is a separate internal QA app and is not part of the
public package example surface.

## Web Note

When running the example on web, allow the serving origin in the Attriax app
configuration. For local development, that usually means allowing the Flutter
dev-server origin you are using, for example `http://localhost:3000`.

## Run It

```bash
cd attriax/example
flutter run
```

## Validate It

```bash
cd attriax/example
flutter test test/main_test.dart
```
