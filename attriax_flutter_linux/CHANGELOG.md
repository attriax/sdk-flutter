# Changelog

## 0.6.0

- First Linux desktop platform release for the Attriax Flutter plugin.
- Added the federated `attriax_flutter_linux` package: a `dart:ffi` binding over
  the prebuilt Attriax KMP core C-ABI shared library (`libattriax_core.so`),
  registering `AttriaxLinux` as `AttriaxPlatform.instance` on Linux.
- Faithful port of the `attriax_flutter_windows` binding (same five C-ABI entry
  points, same `{"ok":…}` dispatch envelope, same caller-frees
  `attriax_free_string` event-callback contract) — the two differ only in the
  shared-library filename and the CMake bundling variable.
