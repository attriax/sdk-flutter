# attriax_android

Android implementation of the Attriax plugin.

This package is a federated implementation detail. Most apps should depend on
`attriax`, not `attriax_android` directly.

## Overview

This package provides the Android platform implementation for the Attriax SDK.

## Architecture

- Package name: `com.attriax.attriax_android`
- Plugin class: `AttriaxAndroidPlugin`
- Platform: Android 5.0+ (API Level 21+)
- Dart wrapper: `lib/src/attriax_android.dart`
- Native handler: `android/src/main/java/com/attriax/attriax_android/AttriaxAndroidPlugin.java`

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
cd flutter-plugin/attriax_android
flutter test
```

### File Structure

```
android/
  ├── build.gradle   # Gradle configuration
  └── src/           # Android source code
lib/
  ├── attriax_android.dart
  └── src/attriax_android.dart
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
