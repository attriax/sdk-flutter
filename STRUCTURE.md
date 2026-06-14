# Attriax Flutter Plugin Structure

## Overview

`sdk-flutter/` is a federated Flutter plugin workspace.

## Packages

```text
sdk-flutter/
├── attriax/                     # Public package surface
│   └── example/                # Minimal public package example app
├── example-gdpr/               # Minimal manual GDPR testing app
├── example-rich/               # Rich public demo app
├── attriax_api_client/         # Generated internal transport client
├── attriax_flutter_platform_interface/ # Shared contracts and types
├── attriax_flutter_android/            # Android implementation
├── attriax_flutter_ios/                # iOS and macOS implementation
└── attriax_flutter_windows/            # Windows implementation
```

The internal QA app is intentionally kept outside this repository at `../flutter-internal-tester/` so it can evolve independently from the publishable SDK packages. It is not part of the public SDK example surface.

The generated transport client stays in its own package so regeneration can replace it atomically without mixing generated and handwritten runtime code.

## Workflow

```bash
cd sdk-flutter
flutter pub get
dart analyze
cd attriax && flutter test
cd ..\example-gdpr && flutter test
cd ..\attriax\example && flutter test
cd ..\..\example-rich && flutter test
cd ..\attriax_flutter_platform_interface && flutter test
cd ..\attriax_flutter_android && flutter test
cd ..\attriax_flutter_ios && flutter test
cd ..\attriax_flutter_windows && flutter test
```

The workspace root does not own a top-level `test/` directory, so `flutter test` should be run from the package directories that contain tests.

```bash
cd sdk-flutter\attriax\example
flutter run
```

```bash
cd sdk-flutter\example-rich
flutter run
```

```bash
cd sdk-flutter\example-gdpr
flutter run
```

```bash
cd flutter-internal-tester
flutter run
```
