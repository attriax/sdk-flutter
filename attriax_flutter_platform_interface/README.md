# attriax_flutter_platform_interface

A common platform interface for the Attriax plugin.

This package is not intended to be added directly to most apps. End users
should depend on `attriax_flutter`.

## Overview

This package defines the abstract platform interface plus the shared public
types used by the Flutter SDK runtime and the federated platform packages. It
should be extended by platform-specific packages like
`attriax_flutter_android` and `attriax_flutter_ios`.

This package appears on pub.dev because federated Flutter plugins need a shared
contract package, but regular applications should still depend on
`attriax_flutter` instead of importing `attriax_flutter_platform_interface`
directly.

## Requirements

- Dart `^3.8.0`
- Flutter `>=3.29.0`

These constraints match the current federated plugin workspace and keep the
shared public types aligned with the main `attriax_flutter` package.

## Architecture

- Provides: platform-agnostic interface definitions plus the shared public
	Flutter SDK type library
- Exports: `attriax_platform_interface.dart` for native hooks and
	`attriax_platform_types.dart` for the stable shared type surface, plus
	`attriax_runtime_types.dart` for the broader runtime-only model set used by
	`attriax_flutter`
- Also exports the shared `MethodChannelAttriax` base used by federated
	packages whose Dart behavior matches the common method-channel flow.
- Used by: `attriax_flutter` plus the federated implementation packages
- Federated implementations: `attriax_flutter_android`,
	`attriax_flutter_ios`, `attriax_flutter_windows`

New platform-facing code should import `attriax_platform_interface.dart`.
Model-only consumers should import `attriax_platform_types.dart`.
Main-package runtime code that still needs internal-only shared models should
import `attriax_runtime_types.dart` instead of the compatibility umbrella.

## Development

This package uses `plugin_platform_interface` to define the shared contract and
the public types used by the federated implementations. The shared type library
is now split across smaller `src/types_*.dart` part files so large runtime
model edits do not have to flow through one monolithic source file. When adding
new platform methods:

1. Add method definition to the interface
2. Implement in each platform package
3. Prefer extending `MethodChannelAttriax` when the shared channel/error
	handling already matches the platform's needs
3. Update the example app to demonstrate usage

Run the package-level regression tests before release:

```bash
cd sdk-flutter/attriax_flutter_platform_interface
flutter test
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
