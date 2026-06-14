# Attriax Flutter SDK Development Guide

## Quick Reference

### Project Structure
- **attriax/** — Main plugin (public API)
- **attriax/RUNTIME_ARCHITECTURE.md** — Maintainer map of runtime ownership, startup flow, and test seams
- **attriax_api_client/** — Generated transport client from the SDK contract
- **attriax_flutter_platform_interface/** — Shared contracts, public/runtime types, and shared method-channel base
- **attriax_flutter_android/** — Android implementation (Dart wrapper + Java plugin)
- **attriax_flutter_ios/** — iOS/macOS implementation (Swift)
- **attriax_flutter_windows/** — Windows implementation on the shared runtime-facing method-channel model
- **attriax/example/** — Minimal public package example app
- **example-rich/** — Rich public demo app kept outside the publishable package
- **../flutter-internal-tester/** — Internal QA app, not part of the public SDK surface

### Runtime Ownership
- **attriax/lib/src/internal/attriax_runtime.dart** — Composition root only; avoid re-centralizing workflow logic here
- **Runtime startup/activation** — private workflows in `attriax_runtime.dart`; keep them explicit and avoid reintroducing callback-only coordinator classes
- **Runtime helper managers** — `attriax_runtime_config_manager.dart`, `attriax_app_open_launcher.dart`, `attriax_crash_reporting_manager.dart`
- **Runtime settings boundary** — `attriax_runtime_settings_state.dart`, `attriax_runtime_settings_store.dart`, plus the narrow store interfaces implemented by `attriax_preferences_store.dart`
- **Context boundary** — `attriax_context_collector.dart` composed from `attriax_context_platform_services.dart`, `attriax_native_context_capture.dart`, `attriax_context_snapshot_builder.dart`, and `attriax_device_identity_resolver.dart`

### Essential Commands

```bash
cd sdk-flutter

# Get dependencies
flutter pub get

# Run analysis
dart analyze

# Format code
dart format .

# Run tests (paths are relative; each cd continues from the previous one)
cd attriax && flutter test
cd example && flutter test
cd ..\..\example-rich && flutter test
cd ..\attriax_flutter_platform_interface && flutter test
cd ..\attriax_flutter_android && flutter test
cd ..\attriax_flutter_ios && flutter test
cd ..\attriax_flutter_windows && flutter test

# Run public example (from the sdk-flutter workspace root)
cd attriax\example && flutter run

# Run rich public demo (from the sdk-flutter workspace root)
cd example-rich && flutter run

# Regenerate the public Windows example wrapper if desktop builds go stale
cd .. && npm run sdk:flutter:example:windows:repair

# Run internal tester (non-public)
cd ..\flutter-internal-tester && flutter run
```

### Regenerate the generated transport client

Run these from the workspace root:

```bash
npm install
npm run sdk:flutter:generate
```

```bash
npm run sdk:flutter:generate:fast
```

```bash
npm run sdk:flutter:validate
```

The supported regeneration flow is documented in [SDK_CLIENT_GENERATION.md](SDK_CLIENT_GENERATION.md).

### Development Checklist

- [ ] Updated `pubspec.yaml` if adding dependencies
- [ ] Regenerated `attriax_api_client` if the SDK API contract changed
- [ ] Ran `dart analyze` — all issues resolved
- [ ] Ran `dart format .` — code is formatted
- [ ] Added/updated tests
- [ ] Updated relevant README files
- [ ] Tested on iOS simulator/device
- [ ] Tested on Android emulator/device
- [ ] Updated `CHANGELOG.md`
- [ ] Committed with clear messages

### File Naming Conventions

- **Dart files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Methods/variables**: `camelCase`
- **Constants**: `camelCase`
- **Private members**: prefix with `_`

### Platform Implementation Pattern

When adding a new feature:

0. **Choose the owning layer first**:
   - runtime workflow or startup policy -> `attriax/lib/src/internal/`
   - shared platform contract -> `attriax_flutter_platform_interface/lib/src/`
   - platform-specific native or method-channel behavior -> the owning federated package

1. **Define interface** in `attriax_flutter_platform_interface/lib/src/`:
   ```dart
   abstract class AttriaxPlatform {
     Future<void> newFeature();
   }
   ```

2. **Implement the federated package**:
   ```dart
   class AttriaxAndroid extends MethodChannelAttriax {
     AttriaxAndroid() : super(logName: 'attriax.android');
   }
   ```

   When the platform behavior matches the shared method-channel flow, prefer
   extending `MethodChannelAttriax` from
   `attriax_flutter_platform_interface/` instead of duplicating
   channel/error-handling code in each federated package. Android and Windows
   should stay on that shared base unless they truly need a divergence.

3. **Handle the method natively** in the platform plugin classes:
   - Android: `attriax_flutter_android/android/src/main/java/.../AttriaxAndroidPlugin.java`
   - iOS: `attriax_flutter_ios/ios/Classes/AttriaxIosPlugin.swift`
   - Windows: `attriax_flutter_windows/windows/attriax_flutter_windows_plugin.cpp`

4. **Expose in main package** in `attriax/lib/attriax.dart` or `attriax/lib/src/attriax.dart`:
   ```dart
   Future<void> newFeature() => _runtime.newFeature();
   ```

5. **Demonstrate package usage** in `attriax/example/lib/main.dart`:
   ```dart
   await Attriax().newFeature();
   ```

6. **Add richer public demo coverage when it helps readers** in `example-rich/lib/main.dart`.

7. **Add tests in the package that owns the logic**:
   - method-channel wrapper tests in the federated package
   - runtime/orchestration tests in `attriax/`
   - minimal example UI tests in `attriax/example/`
   - rich public demo UI/flow tests in `example-rich/` when needed
   - Windows example build validation in `attriax_flutter_windows/example/` when you touch Windows or platform-interface behavior

### Testing

- Use `flutter test` for Dart/Flutter testing
- Use Android Studio or Xcode for native testing
- The workspace root itself has no top-level test directory; run tests in the package folders that own them
- Use `npm run sdk:flutter:validate` from the workspace root after regenerating the SDK client
- When you change Windows or shared platform-interface behavior, also run a Windows example build from `attriax_flutter_windows/example/`
- Test on both simulator and real devices before PR

### Common Issues & Solutions

**Issue**: `.dart_tool/` folder conflicts
- **Solution**: Add to `.gitignore` ✓ (already done)

**Issue**: Build failures on iOS
- **Solution**: Run `pod install` in `attriax_flutter_ios/ios/`

**Issue**: Android build errors
- **Solution**: Run `./gradlew clean` in `attriax_flutter_android/android/`

**Issue**: Windows package example build fails with missing `cpp_client_wrapper` files under `attriax/example/windows/flutter/ephemeral/`
- **Solution**: Run `npm run sdk:flutter:example:windows:repair` from the workspace root. That removes the stale generated Windows wrapper output, refreshes workspace dependencies, and rebuilds the minimal public package example.

### Useful Resources

- [Dart Language Docs](https://dart.dev)
- [Flutter Plugins Documentation](https://docs.flutter.dev/development/plugins-and-packages/plugins)
- [Writing Federated Plugins](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#federated-plugins)
- [Kotlin for Android](https://kotlinlang.org)
- [Swift for iOS](https://developer.apple.com/swift/)

---

Need help? Open an issue or check the [CONTRIBUTING.md](./CONTRIBUTING.md) guide.
