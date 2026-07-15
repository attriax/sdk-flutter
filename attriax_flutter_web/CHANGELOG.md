# Changelog

## 0.6.0

- First web platform release for the Attriax Flutter plugin.
- Added the federated `attriax_flutter_web` package: a `dart:js_interop` binding
  over the sdk-js engine (`@attriax/js`), registering `AttriaxWeb` as
  `AttriaxPlatform.instance` on the web. Flutter web now drives the same engine
  as every other Attriax SDK instead of the in-Dart engine, so a web build
  produces the same wire behavior as the native platforms.
- Implements the full platform interface — lifecycle, event/page-view tracking,
  revenue and ad events, notifications, errors, identify/user properties, deep
  links and dynamic links, receipt validation, GDPR consent, runtime toggles and
  engine reads — and bridges sdk-js's synchronization and deep-link callbacks
  back onto the Dart event streams.
- Vendors the sdk-js IIFE bundle (`assets/attriax_js.js`) and injects it via a
  `<script>` tag at initialize-time (`globalThis.AttriaxJs`).
- Members with no public sdk-js equivalent degrade to documented no-ops or
  defaults rather than throwing (`setCcpaConsent`, `registerPushToken`,
  `requestGdprDataErasure`, `completeInitialDeepLink`, `getRawInstallReferrer`,
  and the iOS-only Apple ATT/SKAN/ASA seams), mirroring the native bindings.
