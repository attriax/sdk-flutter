# attriax_platform_interface

A common platform interface for the Attriax plugin.

This package is not intended to be added directly to most apps. End users
should depend on `attriax`.

## Overview

This package defines the abstract interface and shared public types for Attriax
platform implementations. It should be extended by platform-specific packages
like `attriax_android` and `attriax_ios`.

## Architecture

- Provides: Platform-agnostic interface definitions
- Exports: shared SDK result and synchronization model types
- Used by: `attriax` (main package)
- Implemented by: `attriax_android`, `attriax_ios`

## Development

This package uses `plugin_platform_interface` to define the shared contract and
the public types used by the federated implementations. When adding new
platform methods:

1. Add method definition to the interface
2. Implement in each platform package
3. Update the example app to demonstrate usage

Run the package-level regression tests before release:

```bash
cd flutter-plugin/attriax_platform_interface
flutter test
```

## Contributing

See the parent [README.md](../README.md) for contribution guidelines.
