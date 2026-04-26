# Attriax Flutter Plugin

`flutter-plugin/` is the federated Flutter SDK workspace for Attriax.

It contains the publishable packages plus a public example app. The richer QA app lives in the sibling repository [../flutter-internal-tester](../flutter-internal-tester).

## Workspace Contents

- `attriax/` — main public package
- `attriax_platform_interface/` — shared models and platform contract
- `attriax_android/` — Android implementation
- `attriax_ios/` — iOS implementation
- `attriax/example/` — public example app

## Platform Support

- Android
- iOS
- Web
- Windows
- macOS
- Linux

Android and iOS provide native collection and built-in deep-link listeners. Web resolves the initial URL in Dart. Desktop platforms currently require manual URI forwarding from the host app.

## Getting Started

### Install dependencies

```bash
cd flutter-plugin
flutter pub get
```

### Run analysis and tests

```bash
cd flutter-plugin
dart analyze
flutter test
```

### Run the public example

```bash
cd flutter-plugin\attriax\example
flutter run
```

### Run the internal tester

```bash
cd flutter-internal-tester
flutter pub get
flutter run --dart-define=ATTRIAX_APP_TOKEN=... --dart-define=ATTRIAX_API_BASE_URL=...
```

## Development Notes

- Prefer `await attriax.init()` as the default startup path.
- Use `flutter pub get` at the workspace root unless you intentionally need isolated package resolution.
- Keep the public example simple and package-focused.
- Use the internal tester for richer QA scenarios such as app-open tracking, manual deep-link conversion checks, event submission, and identification flows.

## Release Workflow

See [PUBLISHING.md](PUBLISHING.md) for publish order, dry-run checks, and platform release checklists.

## License

Proprietary. All rights reserved.
