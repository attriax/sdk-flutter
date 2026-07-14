// JS-interop bindings to the `@attriax/js` engine (sdk-js).
//
// The plugin loads the vendored IIFE bundle (`assets/attriax_js.js`), which
// assigns the sdk-js module namespace to `globalThis.AttriaxJs`. These
// `dart:js_interop` extension types mirror the public sdk-js surface 1:1 so the
// Dart web plugin can construct and drive the same engine every other Attriax
// SDK runs. Only the public sdk-js API is bound here — internal shapes are never
// touched.
//
// Wire fidelity note: sdk-js's method names differ from the Attriax platform
// interface; the translation (e.g. `recordAdEvent(eventName)` → the sdk-js ad
// type slug, CCPA gaps, error object construction) lives in `attriax_web.dart`,
// not here. This file is a thin, faithful binding.

import 'dart:js_interop';

/// The sdk-js `Attriax` class, reached at `globalThis.AttriaxJs.Attriax`.
@JS('AttriaxJs.Attriax')
extension type AttriaxJsSdk._(JSObject _) implements JSObject {
  /// `new AttriaxJs.Attriax(config)`.
  external factory AttriaxJsSdk(JSObject config);

  external JSPromise<JSAny?> init(JSObject options);
  external JSPromise<JSAny?> flush();
  external JSPromise<JSAny?> reset();
  external void dispose();

  external JSPromise<JSObject> validateReceipt(JSObject options);

  external bool get isInitialized;
  external bool get isFirstLaunch;
  external bool enabled;
  external String? get deviceId;
  external JSObject? get sdkSnapshot;

  external AttriaxJsTracking get tracking;
  external AttriaxJsConsent get consent;
  external AttriaxJsDeepLinks get deepLinks;
  external AttriaxJsReferrer get referrer;
  external AttriaxJsSynchronization get synchronization;
}

/// sdk-js `attriax.tracking`.
extension type AttriaxJsTracking._(JSObject _) implements JSObject {
  external bool enabled;
  external bool anonymousTrackingEnabled;

  external JSPromise<JSAny?> recordEvent(String eventName, JSObject options);
  external JSPromise<JSAny?> recordPageView(String pageName, JSObject options);
  external JSPromise<JSAny?> recordPurchase(num revenue, JSObject options);
  external JSPromise<JSAny?> recordRefund(num revenue, JSObject options);
  external JSPromise<JSAny?> recordAdRevenue(num revenue, JSObject options);
  external JSPromise<JSAny?> recordAdEvent(String type, JSObject options);
  external JSPromise<JSAny?> recordNotification(
    String type,
    String notificationId,
    JSObject options,
  );
  external JSPromise<JSAny?> recordError(JSObject error, JSObject options);

  external JSPromise<JSAny?> setUser(String? userId, JSObject options);
  external JSPromise<JSAny?> setUserProperty(String name, JSAny? value);
  external JSPromise<JSAny?> setUserProperties(JSObject properties);
  external JSPromise<JSAny?> clearUserProperties(
    JSArray<JSString> propertyNames,
  );
}

/// sdk-js `attriax.consent`.
extension type AttriaxJsConsent._(JSObject _) implements JSObject {
  external AttriaxJsGdprConsent get gdpr;
}

/// sdk-js `attriax.consent.gdpr`.
extension type AttriaxJsGdprConsent._(JSObject _) implements JSObject {
  external String get state;
  external JSObject? get values;
  external bool get isWaitingForConsent;
  external JSPromise<JSBoolean> needsConsent(JSObject options);
  external void setConsent(JSObject options);
  external void setNotRequired();
  external void reset();
}

/// sdk-js `attriax.deepLinks`.
extension type AttriaxJsDeepLinks._(JSObject _) implements JSObject {
  external JSObject? get rawInitialDeepLink;
  external JSObject? get initialDeepLink;
  external bool get initialDeepLinkResolved;
  external JSObject? get latestDeepLink;
  external JSPromise<JSObject?> waitForInitialDeepLink();
  external JSPromise<JSObject> waitResolution(JSObject rawEvent);
  external JSPromise<JSObject> createDynamicLink(JSObject options);
  external JSPromise<JSObject?> recordDeepLink(JSObject options);
  external AttriaxJsDeepLinkStream get stream;
  external AttriaxJsDeepLinkStream get rawStream;
}

/// sdk-js `AttriaxDeepLinkStream` (`{ subscribe(listener): AttriaxSubscription }`).
extension type AttriaxJsDeepLinkStream._(JSObject _) implements JSObject {
  /// Returns an `AttriaxSubscription` — a callable that also carries
  /// `unsubscribe()`. Invoking it (or `.unsubscribe()`) stops the listener.
  external JSFunction subscribe(JSFunction listener);
}

/// sdk-js `attriax.referrer`.
extension type AttriaxJsReferrer._(JSObject _) implements JSObject {
  external JSPromise<JSObject?> getOriginalInstallReferrer();
  external JSPromise<JSObject?> getReinstallReferrer();
  external JSPromise<JSObject?> getSessionReferrer();
  external JSPromise<JSObject?> getLatestDeepLinkReferrer();
}

/// sdk-js `attriax.synchronization`.
extension type AttriaxJsSynchronization._(JSObject _) implements JSObject {
  external String get state;
  external bool get isSynchronized;

  /// Returns an unsubscribe function `() => void`.
  external JSFunction subscribe(JSFunction listener);
}

/// The global `Error` constructor, used to hand sdk-js a real `Error` instance
/// (so its `error instanceof Error` fast-path yields clean crash fields rather
/// than wrapping a plain object and attaching a `rawError` metadata blob).
@JS('Error')
extension type JsError._(JSObject _) implements JSObject {
  external factory JsError(String message);
  external String name;
  external String stack;
}

/// Whether the sdk-js bundle has attached `globalThis.AttriaxJs.Attriax`.
@JS('AttriaxJs')
external JSObject? get _attriaxJsNamespace;

bool get isAttriaxJsLoaded => _attriaxJsNamespace != null;
