# attriax_flutter_windows

Windows implementation package for the Attriax Flutter SDK.

This package is published as the federated Windows implementation that backs
`attriax_flutter` on Windows. Most apps should depend on `attriax_flutter`
instead of importing this package directly.

## Overview

- Registers `AttriaxWindows` as `AttriaxPlatform.instance` on Windows.
- Extends the shared `MethodChannelAttriax` base from
	`attriax_flutter_platform_interface` instead of maintaining a separate
	compatibility wrapper surface.
- Exposes the shared runtime-facing platform methods used by
	`attriax_flutter`, such as native context collection and install-referrer
	queries.

The package no longer carries the template-style `getPlatformVersion()` API.
Windows should look like the Android and iOS federated packages at the Dart
layer unless a Windows-specific divergence is intentional and documented.

## Usage

Add `attriax_flutter` to your Flutter app for the public cross-platform API.
Flutter will register `attriax_flutter_windows` automatically on Windows.

## Development

This repository keeps the Windows plugin package in the `sdk-flutter/`
workspace alongside the main `attriax_flutter` package and the shared API
client. Run workspace dependency resolution from the workspace root when
developing locally.

When the Windows Dart behavior matches the shared method-channel path, keep the
implementation on top of `MethodChannelAttriax` instead of re-introducing a
Windows-only wrapper API.

The package `example/` app validates the shared runtime-facing path and keeps a
local workspace override for `attriax_flutter_platform_interface` during local
development so changes in the shared interface are exercised immediately.

## Validation

```bash
cd sdk-flutter/attriax_flutter_windows
dart analyze
flutter test
cd example && flutter build windows --debug
```

Use the workspace-root `npm run sdk:flutter:example:windows:repair` helper if
the example's generated Windows wrapper output goes stale.

