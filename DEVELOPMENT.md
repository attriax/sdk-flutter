# Attriax Flutter SDK Development Guide

## Quick Reference

### Project Structure
- **attriax/** — Main plugin (public API)
- **attriax_platform_interface/** — Platform interface definitions
- **attriax_android/** — Android implementation (Kotlin)
- **attriax_ios/** — iOS implementation (Swift)
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
flutter test

# Run public example
cd attriax\example && flutter run

# Run internal tester
cd ..\flutter-internal-tester && flutter run
```

### Development Checklist

- [ ] Updated `pubspec.yaml` if adding dependencies
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
   ```kotlin
   class AttriaxAndroidPlugin: AttriaxPlatform {
     override suspend fun newFeature() { ... }
   }
   ```

3. **Implement iOS** in `attriax_ios/lib/src/`:
   ```swift
   class AttriaxIosPlugin: AttriaxPlatform {
     func newFeature() async throws { ... }
   }
   ```

4. **Expose in main package** in `attriax/lib/attriax.dart`:
   ```dart
   Future<void> newFeature() => _platform.newFeature();
   ```

5. **Demonstrate publicly** in `attriax/example/lib/main.dart` and add deeper validation to `../flutter-internal-tester/lib/main.dart`:
   ```dart
   await Attriax().newFeature();
   ```

### Testing

- Use `flutter test` for Dart/Flutter testing
- Use Android Studio or Xcode for native testing
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
