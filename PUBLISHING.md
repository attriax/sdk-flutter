# Attriax Flutter Publishing Notes

This document covers the release workflow and the production nuances that need
to be checked before publishing the Flutter SDK packages to pub.dev.

## Release Order

Publish the packages in this order so hosted dependency constraints resolve
cleanly:

1. `attriax_flutter_platform_interface`
2. `attriax_api_client`
3. `attriax_flutter_android`
4. `attriax_flutter_ios`
5. `attriax_flutter_windows`
6. `attriax_flutter`

Keep versions aligned unless there is a strong reason to version a federated
package independently. The Android Gradle project and iOS podspec derive their
native package versions from their package `pubspec.yaml`; if a future toolchain
breaks that derivation, update the native metadata manually during release.

Publishing is intentionally manual. CI may run validation in the future, but it
must not publish packages automatically.

## Local Development

The publishable packages use hosted dependency constraints because that is
required for pub.dev publishing.

Local SDK development happens through the `sdk-flutter/` Dart workspace.
The sibling `flutter-internal-tester/` repository uses `pubspec_overrides.yaml`
to point at the local workspace packages.

## Required Release Checks

Run these commands before every release:

```bash
npm run sdk:flutter:generate
npm run flutter:release:check
```

Run the release flow from a clean git state. `dart pub publish --dry-run`
returns a non-zero exit code when checked-in files are modified, even if the
package contents themselves are otherwise valid.

The workspace root itself does not have a top-level `flutter test` entrypoint,
so `npm run flutter:release:check` runs package-scoped checks under the hood.
It refreshes workspace dependencies, checks formatting, analyzes all Flutter
SDK packages, and runs the package tests.

Then run publish dry-runs for each package in release order:

```bash
npm run flutter:publish:dry-run
```

When every dry-run is clean, publish manually from the root:

```bash
npm run flutter:publish
```

The publish helper follows the release order above and delegates to
`dart pub publish`, so it still uses pub.dev's normal manual confirmation flow.

## Android Checklist

- Verify deep links on cold start, warm start, and resumed app flows.
- Verify `android:autoVerify="true"` app links against the real production
  `assetlinks.json` configuration.
- Test at least one Play-distributed build because the Play Install Referrer
  API does not fully represent sideloaded installs.
- Re-check Play Console Data safety declarations whenever collected fields or
  identifiers change. Attriax can collect Android ID, Google Advertising ID
  when `collectAdvertisingId` is enabled, install-referrer data, app/device
  context, crash reports when `automaticCrashReportingEnabled` is enabled, and
  analytics/deep-link payloads submitted by the host app.
- Keep `compileSdk`, Java target, and Android Gradle Plugin versions aligned
  with the Flutter stable toolchain used for release.

## iOS Checklist

- Build and test on macOS before every release. This cannot be fully validated
  from Windows.
- Verify universal links on cold start, warm start, and resumed app flows.
- Re-check Associated Domains entitlements and the production AASA file.
- Confirm the packaged `attriax_flutter_ios` privacy manifests still match the native
  code paths being shipped. The bundled manifests cover SDK-owned native usage,
  but host apps still need their own App Store privacy labels and any app-level
  tracking declarations.
- Remember that `identifierForVendor` can change after reinstall/vendor changes;
  do not treat it as a permanent account identifier.
- Update App Store privacy disclosures whenever collected fields or identifiers
  change. Attriax can collect IDFV, an SDK keychain device ID, IDFA only after
  App Tracking Transparency authorization and when `collectAdvertisingId` is
  enabled, app/device context, crash reports when `automaticCrashReportingEnabled`
  is enabled, and analytics/deep-link payloads submitted by the host app.

## Web Checklist

- Run `flutter build web` on the public example before release.
- Verify that the hosting environment preserves the full incoming URL,
  including query parameters, until Flutter boots and the SDK initializes.
- Verify that the production SDK endpoints answer browser CORS preflights.
- Test direct entry, refresh, and deep-link navigation on the production host.

## Other Platforms

- Windows now ships through the federated `attriax_flutter_windows` package.
  Validate the Windows example app, native plugin registration, and local publish
  dry-run output before the main `attriax_flutter` package release.
- Linux still uses the Dart-side SDK path without a federated native package.
- macOS is implemented through `attriax_flutter_ios`. Validate connectivity
  changes, persistence behavior, app-open tracking, and the bundled macOS
  privacy manifest there after any runtime change.

## Documentation Expectations

- Keep the public package example focused on package usage only.
- Keep internal QA instructions in the internal tester app or this document, not in the public example.
- Update every package `CHANGELOG.md` when shipping a new release.

## Licensing Note

The Flutter SDK packages are published under Apache-2.0 so customers and
security reviewers can inspect the client code. That does not change the
commercial terms of the hosted Attriax service or private backend repositories.