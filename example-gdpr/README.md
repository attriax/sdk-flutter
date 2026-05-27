# example_gdpr

Minimal manual GDPR example for the Attriax Flutter SDK.

## Purpose

This app stays idle until you press `Init SDK`. It gives you direct buttons for:

- local and remote GDPR checks
- toggling anonymous tracking on or off
- applying custom consent values
- grant all, deny all, set not required, and reset consent
- GDPR data erasure
- recording a demo event and page view
- setting and clearing a demo user

`Init SDK` does not call `needsConsent()` for you. Local and remote GDPR checks stay manual so you can test the raw startup behavior first, then explicitly trigger a local-only or remote consent check when you want to compare flows. While GDPR state is still `unknown` or `pending`, the SDK can keep anonymous-capable session and analytics traffic flowing without `deviceId` fields, or you can switch anonymous tracking off to buffer that traffic locally until consent resolves.

The default API base URL is `http://localhost:3000`, which matches a locally started API. If you are running the Docker development stack and want the host-exposed API port instead, switch the field to `http://localhost:33000`.

## Run

```bash
cd example-gdpr
flutter run --dart-define=ATTRIAX_APP_TOKEN=your_app_token
```

Optional override:

```bash
flutter run --dart-define=ATTRIAX_APP_TOKEN=your_app_token --dart-define=ATTRIAX_API_BASE_URL=http://localhost:33000
```

## Validate

```bash
cd example-gdpr
flutter test test/widget_test.dart
```
