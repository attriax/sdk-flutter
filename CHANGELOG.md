# Changelog

All notable changes to the Attriax Flutter SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Versioned SDK request contract for app opens, deep-link resolution, events, and identify calls
- Cross-platform context collection for Android, iOS, web, Windows, macOS, and Linux
- Offline queueing, raw deep-link callbacks, conversion callbacks, and runtime enable toggles
- Package example app in `attriax/example/` and internal tester in `../flutter-internal-tester/`

### Changed
- Flutter package versions moved to `1.0.0` before first publication
- Public docs now point to the package example and document app-version overrides

### Deprecated

### Removed

### Fixed
- SDK endpoints now answer browser CORS preflights for web integrations

### Security

## [1.0.0] - 2026-04-21

### Added
- First public-ready Attriax Flutter SDK release
- Federated plugin architecture with Android and iOS platform packages
- Dart-side support for web and desktop collection paths
- Versioned SDK request payloads with app and package version reporting
- Public example app and internal tester app

[Unreleased]: https://github.com/yourusername/attriax/compare/v1.0.0...main
[1.0.0]: https://github.com/yourusername/attriax/releases/tag/v1.0.0
