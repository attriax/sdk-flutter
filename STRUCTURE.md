# Attriax Flutter Plugin Structure

## Overview

`flutter-plugin/` is a federated Flutter plugin workspace.

## Packages

```text
flutter-plugin/
├── attriax/                    # Public package surface
│   └── example/               # Public example app
├── attriax_platform_interface/ # Shared contracts and types
├── attriax_android/            # Android implementation
└── attriax_ios/                # iOS implementation
```

The internal QA app is intentionally kept outside this repository at `../flutter-internal-tester/` so it can evolve independently from the publishable SDK packages.

## Workflow

```bash
cd flutter-plugin
flutter pub get
dart analyze
flutter test
```

```bash
cd flutter-plugin\attriax\example
flutter run
```

```bash
cd flutter-internal-tester
flutter run
```
