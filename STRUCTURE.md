# Attriax Flutter Plugin Structure

## Overview

`flutter-plugin/` is a federated Flutter plugin workspace.

## Packages

```text
flutter-plugin/
├── attriax/                     # Public package surface
│   └── example/                # Public example app
├── attriax_sdk_client/         # Generated internal transport client
├── attriax_platform_interface/ # Shared contracts and types
├── attriax_android/            # Android implementation
└── attriax_ios/                # iOS and macOS implementation
```

The internal QA app is intentionally kept outside this repository at `../flutter-internal-tester/` so it can evolve independently from the publishable SDK packages.

The generated transport client stays in its own package so regeneration can replace it atomically without mixing generated and handwritten runtime code.

## Workflow

```bash
cd flutter-plugin
flutter pub get
dart analyze
cd attriax && flutter test
cd ..\attriax\example && flutter test
cd ..\..\attriax_platform_interface && flutter test
cd ..\attriax_android && flutter test
cd ..\attriax_ios && flutter test
```

The workspace root does not own a top-level `test/` directory, so `flutter test` should be run from the package directories that contain tests.

```bash
cd flutter-plugin\attriax\example
flutter run
```

```bash
cd flutter-internal-tester
flutter run
```
