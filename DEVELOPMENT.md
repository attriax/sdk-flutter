# Attriax Flutter SDK Development Guide

## Quick Reference

### Project Structure
- **attriax/** — Main plugin (public API)
- **attriax_sdk_client/** — Generated transport client from the SDK contract
- **attriax_platform_interface/** — Platform interface definitions
- **attriax_android/** — Android implementation (Dart wrapper + Java plugin)
- **attriax_ios/** — iOS/macOS implementation (Swift)
- **attriax/example/** — Simple public example app
- **../flutter-internal-tester/** — Internal testing app

### Essential Commands

```bash
cd flutter-plugin

# Get dependencies
flutter pub get

# Run analysis
dart analyze

# Format code
dart format .

# Run tests
cd attriax && flutter test
cd ..\attriax\example && flutter test
cd ..\..\attriax_platform_interface && flutter test
cd ..\attriax_android && flutter test
cd ..\attriax_ios && flutter test

# Run public example
cd attriax\example && flutter run

# Run internal tester
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
- [ ] Regenerated `attriax_sdk_client` if the SDK API contract changed
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

1. **Define interface** in `attriax_platform_interface/lib/src/`:
   ```dart
   abstract class AttriaxPlatform {
     Future<void> newFeature();
   }
   ```

2. **Implement Android** in `attriax_android/lib/src/`:
   ```dart
    class AttriaxAndroid extends MethodChannelAttriax {
       AttriaxAndroid() : super(logName: 'attriax.android');
   }
   ```

    When the platform behavior matches the shared method-channel flow, prefer extending `MethodChannelAttriax` from `attriax_platform_interface/` instead of duplicating channel/error-handling code in each federated package.

3. **Handle the method natively** in the platform plugin classes:
   - Android: `attriax_android/android/src/main/java/.../AttriaxAndroidPlugin.java`
   - iOS: `attriax_ios/ios/Classes/AttriaxIosPlugin.swift`

4. **Expose in main package** in `attriax/lib/attriax.dart` or `attriax/lib/src/attriax.dart`:
   ```dart
   Future<void> newFeature() => _runtime.newFeature();
   ```

5. **Demonstrate publicly** in `attriax/example/lib/main.dart` and add deeper validation to `../flutter-internal-tester/lib/main.dart`:
   ```dart
   await Attriax().newFeature();
   ```

6. **Add tests in the package that owns the logic**:
   - method-channel wrapper tests in the federated package
   - runtime/orchestration tests in `attriax/`
   - example UI/flow tests in `attriax/example/`

### Testing

- Use `flutter test` for Dart/Flutter testing
- Use Android Studio or Xcode for native testing
- The workspace root itself has no top-level test directory; run tests in the package folders that own them
- Use `npm run sdk:flutter:validate` from the workspace root after regenerating the SDK client
- Test on both simulator and real devices before PR

### Common Issues & Solutions

**Issue**: `.dart_tool/` folder conflicts
- **Solution**: Add to `.gitignore` ✓ (already done)

**Issue**: Build failures on iOS
- **Solution**: Run `pod install` in `attriax_ios/ios/`

**Issue**: Android build errors
- **Solution**: Run `./gradlew clean` in `attriax_android/android/`

### Useful Resources

- [Dart Language Docs](https://dart.dev)
- [Flutter Plugins Documentation](https://docs.flutter.dev/development/plugins-and-packages/plugins)
- [Writing Federated Plugins](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#federated-plugins)
- [Kotlin for Android](https://kotlinlang.org)
- [Swift for iOS](https://developer.apple.com/swift/)

---

Need help? Open an issue or check the [CONTRIBUTING.md](./CONTRIBUTING.md) guide.
