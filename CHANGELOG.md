# Changelog

All notable changes to the Attriax Flutter SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-05-13

### Added
- Reinstall attribution and app-data-clear classification in the Flutter SDK app-open flow.
- A dedicated `referrer` facade with original-install, reinstall, session, and latest deep-link lookups.
- Richer deep-link and startup-referrer payloads with canonical URIs, UTM data, and Android install-referrer timestamps.

### Changed
- Breaking: removed the public `Attriax.installReferrer` getter in favor of `Attriax.referrer.*` async methods.
- Startup deep-link handling now exposes the initial event first and lets callers resolve it explicitly, matching the foreground stream flow.
- Deferred deep-link startup handling now suppresses app-data-clear launches while still surfacing reinstall attribution.
- Federated Flutter packages and the generated Dart API client now release as `0.1.0` together.

## [0.0.2] - 2026-05-10

### Added
- Windows support through the new federated `attriax_flutter_windows` package.

## [0.0.1] - 2026-05-08

### Added
- First public-ready Attriax Flutter SDK release
- Federated plugin architecture with Android and iOS platform packages
- Dart-side support for web and desktop collection paths
- Versioned SDK request payloads with app and package version reporting
- Public example app and internal tester app
