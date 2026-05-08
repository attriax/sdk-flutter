# attriax_flutter_android

Android implementation of the Attriax plugin.

This package is a federated implementation detail. Most apps should depend on
`attriax_flutter`, not `attriax_flutter_android` directly.

## Overview

This package provides the Android platform implementation for the Attriax SDK.
It is published so the federated `attriax_flutter` package can resolve Android support
from pub.dev. Most apps should not import `attriax_flutter_android` directly unless
they are developing or debugging the Android implementation itself.

Android-specific privacy and store-submission guidance lives in the main
`attriax_flutter` README, the setup page in the web dashboard, and `../PUBLISHING.md`.

## Requirements

- Dart `^3.8.0`
- Flutter `>=3.29.0`
- Android 5.0+ / API Level 21+

These floors match the package `pubspec.yaml` and Android implementation
support matrix used by the main `attriax_flutter` package.

## Architecture

- Package name: `com.attriax.attriax_flutter_android`
- Plugin class: `AttriaxAndroidPlugin`
- Platform: Android 5.0+ (API Level 21+)
- Dart wrapper: `lib/src/attriax_flutter_android.dart`
- Native handler: `android/src/main/java/com/attriax/attriax_flutter_android/AttriaxAndroidPlugin.java`

## Development

### Prerequisites

- Android SDK ≥ API Level 21
- Kotlin ≥ 1.8

### Validation

Validate this package through the public example or an integration app. The
Android implementation should be checked against real app links and at least
one Play-distributed install when verifying install referrer behavior.


Run the package-level regression tests before release:

```bash
cd sdk-flutter/attriax_flutter_android
flutter test
```

### File Structure

```
android/
  ├── build.gradle   # Gradle configuration
  └── src/           # Android source code
lib/
  ├── attriax_flutter_android.dart
  └── src/attriax_flutter_android.dart
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
