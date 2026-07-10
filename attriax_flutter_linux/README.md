# attriax_flutter_linux

Linux implementation package for the Attriax Flutter SDK.

This package is published as the federated Linux implementation that backs
`attriax_flutter` on Linux desktop. Most apps should depend on `attriax_flutter`
instead of importing this package directly.

## Overview

- Registers `AttriaxLinux` as `AttriaxPlatform.instance` on Linux.
- Drives the shared Attriax Kotlin Multiplatform core through its C-ABI shared
  library (`libattriax_core.so`) over `dart:ffi`, mirroring the Windows
  (`attriax_core.dll`) binding method-for-method — the two differ only in the
  shared-library filename.
- The authoritative SDK state (identity, queue, consent, sessions, sync) lives
  in the native engine; this package holds only the FFI handle, the
  event-callback trampoline, and the stream controllers that re-surface engine
  callbacks as Dart streams.

## Usage

Add `attriax_flutter` to your Flutter app for the public cross-platform API.
Flutter will register `attriax_flutter_linux` automatically on Linux.

## Development

This repository keeps the Linux plugin package in the `sdk-flutter/` workspace
alongside the main `attriax_flutter` package and the shared platform interface.
Run workspace dependency resolution from the workspace root when developing
locally.

The Linux binding is a faithful `dart:ffi` port of `attriax_flutter_windows`;
keep the two aligned except where a platform-specific divergence (the
shared-library filename, the CMake bundling variable) is intentional.

## Validation

```bash
cd sdk-flutter/attriax_flutter_linux
dart analyze
flutter test
cd example && flutter build linux --debug
```

Building/running on Linux requires a Linux host with the Flutter Linux desktop
toolchain (clang, cmake, ninja, GTK dev headers); it cannot be built on Windows.
