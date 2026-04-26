# Attriax Flutter Publishing Notes

This document covers the release workflow and the production nuances that need
to be checked before publishing the Flutter SDK packages to pub.dev.

## Release Order

Publish the packages in this order so hosted dependency constraints resolve
cleanly:

1. `attriax_platform_interface`
2. `attriax_android`
3. `attriax_ios`
4. `attriax`

Keep versions aligned unless there is a strong reason to version a federated
package independently.

## Local Development

The publishable packages use hosted dependency constraints because that is
required for pub.dev publishing.

Local SDK development happens through the `flutter-plugin/` Dart workspace.
The sibling `flutter-internal-tester/` repository uses `pubspec_overrides.yaml`
to point at the local workspace packages.

## Required Release Checks

Run these commands before every release:

```bash
cd flutter-plugin && flutter pub get
cd attriax && flutter analyze lib/
cd ..\attriax_platform_interface && flutter analyze
cd ..\attriax_android && flutter analyze
cd ..\attriax_ios && flutter analyze
cd ..\attriax\example && flutter analyze lib/ && flutter build web && flutter build apk --debug
cd ..\..\flutter-internal-tester && flutter pub get && flutter analyze lib/
```

Then run publish dry-runs for each package in release order:

```bash
cd flutter-plugin\attriax_platform_interface && dart pub publish --dry-run
cd ..\attriax_android && dart pub publish --dry-run
cd ..\attriax_ios && dart pub publish --dry-run
cd ..\attriax && dart pub publish --dry-run
```

## Android Checklist

- Verify deep links on cold start, warm start, and resumed app flows.
- Verify `android:autoVerify="true"` app links against the real production
  `assetlinks.json` configuration.
- Test at least one Play-distributed build because the Play Install Referrer
  API does not fully represent sideloaded installs.
- Re-check Play Console Data safety declarations whenever collected fields or
  identifiers change.
- Keep `compileSdk`, Java target, and Android Gradle Plugin versions aligned
  with the Flutter stable toolchain used for release.

## iOS Checklist

- Build and test on macOS before every release. This cannot be fully validated
  from Windows.
- Verify universal links on cold start, warm start, and resumed app flows.
- Re-check Associated Domains entitlements and the production AASA file.
- Remember that `identifierForVendor` can change after reinstall/vendor changes;
  do not treat it as a permanent account identifier.
- Update App Store privacy disclosures whenever collected fields or identifiers
  change.

## Web Checklist

- Run `flutter build web` on the public example before release.
- Verify that the hosting environment preserves the full incoming URL,
  including query parameters, until Flutter boots and the SDK initializes.
- Verify that the production SDK endpoints answer browser CORS preflights.
- Test direct entry, refresh, and deep-link navigation on the production host.

## Other Platforms

- Windows, macOS, and Linux use the Dart-side SDK path without federated native
  packages. Validate connectivity changes, persistence behavior, and app-open
  tracking there after any runtime change.

## Documentation Expectations

- Keep the public package example focused on package usage only.
- Keep internal QA instructions in the internal tester app or this document, not in the public example.
- Update every package `CHANGELOG.md` when shipping a new release.

## Licensing Note

Each publishable package currently includes a proprietary license file to
satisfy pub.dev packaging requirements. Confirm that this matches the intended
commercial distribution model before the first public release.