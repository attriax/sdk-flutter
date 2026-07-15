# attriax_flutter_web

Web implementation package for the Attriax Flutter SDK.

This package is published as the federated web implementation that backs
`attriax_flutter` on the web. Most apps should depend on `attriax_flutter`
instead of importing this package directly.

## Overview

- Registers `AttriaxWeb` as `AttriaxPlatform.instance` on the web.
- Drives the sdk-js engine (`@attriax/js`) over `dart:js_interop`, forwarding
  every engine command and event to it, so a Flutter web build produces the same
  wire behavior as every other Attriax SDK.
- Vendors the sdk-js IIFE bundle as `assets/attriax_js.js` (built from the
  sibling `sdk-js` repository, `dist/index.global.js`) and injects it via a
  `<script>` tag at initialize-time; it assigns the SDK to `globalThis.AttriaxJs`.
- The authoritative SDK state (identity, queue, consent, sessions, sync) lives in
  sdk-js; this package holds only the JS bridge and the stream controllers that
  re-surface sdk-js's callbacks as Dart streams.
- Members with no public sdk-js equivalent (`setCcpaConsent`,
  `registerPushToken`, `requestGdprDataErasure`, `getRawInstallReferrer`, and the
  iOS-only Apple ATT/SKAN/ASA seams) degrade to documented no-ops or defaults
  rather than throwing, mirroring the native bindings.

## Usage

Add `attriax_flutter` to your Flutter app for the public cross-platform API.
Flutter will register `attriax_flutter_web` automatically on the web.

## Development

This repository keeps the web plugin package in the `sdk-flutter/` workspace
alongside the main `attriax_flutter` package and the shared platform interface.
Run workspace dependency resolution from the workspace root when developing
locally.

When the sdk-js engine changes, rebuild its IIFE bundle in the `sdk-js`
repository and re-vendor `dist/index.global.js` into `assets/attriax_js.js`.

## Validation

```bash
cd sdk-flutter/attriax_flutter_web
dart analyze
cd ../attriax/example && flutter build web --debug
```
