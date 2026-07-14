import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ffi';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:ffi/ffi.dart';

import 'ffi/attriax_core_bindings.dart';

/// Linux desktop implementation of [AttriaxPlatform].
///
/// Under the native-engine re-wrap, Flutter-Linux stops running the in-Dart
/// engine and instead drives the shared Kotlin Multiplatform core — Attriax's
/// reference engine — through its C-ABI shared library (`libattriax_core.so`)
/// over `dart:ffi`. Every command forwards to [AttriaxCoreBindings.dispatch] as
/// a `{"ok":…}` JSON envelope, mirroring the JNI (Android) and JS (web) bindings
/// method-for-method; the authoritative state (identity, queue, consent,
/// sessions, sync) lives in the native engine, so this class holds no engine
/// logic — only the FFI handle, the event-callback trampoline, and the stream
/// controllers that re-surface the engine's callbacks as Dart streams.
///
/// ## Threading / synchronous dispatch
/// `attriax_dispatch` is synchronous (the native transport is `runBlocking`
/// bridged). The hot-path commands (init / tracking / toggles / reads) merely
/// enqueue work and return immediately; the engine performs network flushes on
/// its own background threads, so calling them on the platform isolate does not
/// block on I/O. The two genuinely blocking commands — [validateReceipt] and,
/// when supported, [createDynamicLink] — run their network round-trip on the
/// calling isolate.
///
/// ## Members degraded because the C-ABI does not (yet) route them
/// Each is a benign no-op / default rather than a throw, matching the other
/// bindings' deferred set:
/// - [setEventTrackingEnabled] / [getEventTrackingEnabled] — the C-ABI exposes
///   only the whole-SDK `enabled` toggle, not the separate tracking flag.
/// - [completeInitialDeepLink], [waitForInitialDeepLink],
///   [waitForDeepLinkResolution] — the C-ABI resolves the launch link itself and
///   routes no blocking wait; the facade falls back to the deep-link stream.
/// - [createDynamicLink] — not routed by the desktop engine; throws (there is no
///   nullable result to degrade to).
/// - [rawDeepLinkEvents] / [initialDeepLinkResolutions] streams — the C-ABI wires
///   only the resolved-deep-link and synchronization-state listeners, so these
///   remain empty (base default).
/// - Apple seams ([submitAsaToken], [setTrackingAuthorizationStatus], SKAN) —
///   forwarded for fidelity but inert on the desktop engine.
class AttriaxLinux extends AttriaxPlatform {
  /// [bindings] is an injection seam for tests; production callers omit it and
  /// the plugin loads the bundled `libattriax_core.so` on [initialize].
  AttriaxLinux({AttriaxCoreBindings? bindings}) : _injectedBindings = bindings;

  /// Registers this class as the Linux implementation of `attriax_flutter`.
  static void registerWith() {
    AttriaxPlatform.instance = AttriaxLinux();
  }

  static const String _logName = 'attriax.linux';

  final AttriaxCoreBindings? _injectedBindings;
  AttriaxCoreBindings? _bindings;

  /// Opaque `StableRef` handle returned by `attriax_create`.
  Pointer<Void> _handle = nullptr;

  /// `NativeCallable.listener` trampoline for the engine event callback. The
  /// engine may invoke the callback on a background thread, so `.listener`
  /// (asynchronous, thread-safe delivery to this isolate) is required — a
  /// `.isolateLocal` callback would be undefined behavior off the isolate's
  /// thread.
  NativeCallable<AttriaxEventCallbackC>? _eventCallable;

  final StreamController<AttriaxSynchronizationState> _syncController =
      StreamController<AttriaxSynchronizationState>.broadcast();
  final StreamController<AttriaxDeepLinkEvent> _deepLinkController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();

  bool get _isInitialized => _handle != nullptr;

  // ---------------------------------------------------------------------------
  // Lifecycle.
  // ---------------------------------------------------------------------------

  @override
  Future<void> initialize(AttriaxConfig config) async {
    if (_isInitialized) {
      return;
    }
    final bindings = _injectedBindings ?? AttriaxCoreBindings.open();
    _bindings = bindings;

    final configPtr = jsonEncode(config.toJson()).toNativeUtf8();
    try {
      // dataDir left null → the engine uses AttriaxDesktopNative.defaultDataDir.
      final handle = bindings.create(configPtr, nullptr);
      if (handle == nullptr) {
        throw StateError('attriax_create returned a null handle.');
      }
      _handle = handle;

      final callable = NativeCallable<AttriaxEventCallbackC>.listener(
        _onNativeEvent,
      );
      _eventCallable = callable;
      bindings.registerEventCallback(handle, callable.nativeFunction, nullptr);

      _dispatch('init');
    } finally {
      malloc.free(configPtr);
    }
  }

  @override
  Future<void> flush() async => _invokeVoid('flush');

  @override
  Future<void> reset() async => _invokeVoid('reset');

  @override
  Future<void> dispose() async {
    final bindings = _bindings;
    final handle = _handle;
    if (bindings != null && handle != nullptr) {
      try {
        bindings.registerEventCallback(handle, nullptr, nullptr);
        _dispatch('dispose');
      } on Object catch (error, stackTrace) {
        _log('dispose', error, stackTrace);
      }
      bindings.destroy(handle);
    }
    _handle = nullptr;
    _eventCallable?.close();
    _eventCallable = null;
    await _syncController.close();
    await _deepLinkController.close();
  }

  // ---------------------------------------------------------------------------
  // Tracking — events / page views.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordEvent(
    String name, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) async => _invokeVoid('recordEvent', <String, Object?>{
    'name': name,
    'eventData': eventData,
    'flushImmediately': flushImmediately,
  });

  @override
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) async => _invokeVoid('recordPageView', <String, Object?>{
    'pageName': pageName,
    'pageClass': pageClass,
    'pageTitle': pageTitle,
    'previousPageName': previousPageName,
    'parameters': parameters,
    'source': source,
    'flushImmediately': flushImmediately,
  });

  // ---------------------------------------------------------------------------
  // Tracking — revenue / ad events.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordPurchase({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    String? validationProvider,
    String? validationEnvironment,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? isRenewal,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? validationId,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async => _invokeVoid('recordPurchase', <String, Object?>{
    'revenue': revenue,
    'currency': currency,
    'revenueInMicros': revenueInMicros,
    'purchaseType': purchaseType,
    'productId': productId,
    'transactionId': transactionId,
    'originalTransactionId': originalTransactionId,
    'validationProvider': validationProvider,
    'validationEnvironment': validationEnvironment,
    'purchaseToken': purchaseToken,
    'receiptData': receiptData,
    'signedPayload': signedPayload,
    'receiptSignature': receiptSignature,
    'isRenewal': isRenewal,
    'quantity': quantity,
    'store': store,
    'packageName': packageName,
    'voided': voided,
    'test': test,
    'validationId': validationId,
    'metadata': metadata,
    'flushImmediately': flushImmediately,
  });

  @override
  Future<void> recordRefund({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? reason,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async => _invokeVoid('recordRefund', <String, Object?>{
    'revenue': revenue,
    'currency': currency,
    'revenueInMicros': revenueInMicros,
    'purchaseType': purchaseType,
    'productId': productId,
    'transactionId': transactionId,
    'originalTransactionId': originalTransactionId,
    'quantity': quantity,
    'store': store,
    'packageName': packageName,
    'voided': voided,
    'test': test,
    'reason': reason,
    'metadata': metadata,
    'flushImmediately': flushImmediately,
  });

  @override
  Future<void> recordAdRevenue({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? adNetwork,
    String? adFormat,
    String? adType,
    String? adPlacement,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async => _invokeVoid('recordAdRevenue', <String, Object?>{
    'revenue': revenue,
    'currency': currency,
    'revenueInMicros': revenueInMicros,
    'adNetwork': adNetwork,
    'adFormat': adFormat,
    'adType': adType,
    'adPlacement': adPlacement,
    'test': test,
    'metadata': metadata,
    'flushImmediately': flushImmediately,
  });

  @override
  Future<void> recordAdEvent({
    required String eventName,
    String? adNetwork,
    String? mediationNetwork,
    String? adUnitId,
    String? adPlacement,
    String? adFormat,
    String? adType,
    String? failureReason,
    num? loadLatencyMs,
    String? rewardType,
    num? rewardAmount,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) async {
    // The platform interface sends the resolved reserved event name (e.g.
    // "ad_show_failed") under `eventName`; the C-ABI router resolves it back to
    // the `AttriaxAdEventType` whose name/eventName matches (arg key `type`),
    // so the engine's field->eventData lowering runs.
    await _invokeVoid('recordAdEvent', <String, Object?>{
      'type': eventName,
      'adNetwork': adNetwork,
      'mediationNetwork': mediationNetwork,
      'adUnitId': adUnitId,
      'adPlacement': adPlacement,
      'adFormat': adFormat,
      'adType': adType,
      'failureReason': failureReason,
      'loadLatencyMs': loadLatencyMs,
      'rewardType': rewardType,
      'rewardAmount': rewardAmount,
      'test': test,
      'metadata': metadata,
      'flushImmediately': flushImmediately,
    });
  }

  // ---------------------------------------------------------------------------
  // Tracking — notifications / errors.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordNotification({
    required String type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    String? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) async => _invokeVoid('recordNotification', <String, Object?>{
    'type': type,
    'notificationId': notificationId,
    'linkId': linkId,
    'campaignId': campaignId,
    'title': title,
    'source': source,
    'payload': payload,
    'metadata': metadata,
    'flushImmediately': flushImmediately,
  });

  @override
  Future<void> recordError({
    required String message,
    required String exceptionType,
    String? stackTrace,
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) async => _invokeVoid('recordError', <String, Object?>{
    'message': message,
    'exceptionType': exceptionType,
    'stackTrace': stackTrace,
    'fatal': fatal,
    'source': source,
    'reason': reason,
    'metadata': metadata,
  });

  // ---------------------------------------------------------------------------
  // Tracking — identify / user properties.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setUser({String? userId, String? userName}) async =>
      _invokeVoid('setUser', <String, Object?>{
        'userId': userId,
        'userName': userName,
      });

  @override
  Future<void> setUserProperty(String name, Object? value) async =>
      _invokeVoid('setUserProperty', <String, Object?>{
        'name': name,
        'value': value,
      });

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async =>
      _invokeVoid('setUserProperties', <String, Object?>{
        'properties': properties,
      });

  @override
  Future<void> clearUserProperties({List<String>? propertyNames}) async =>
      _invokeVoid('clearUserProperties', <String, Object?>{
        'propertyNames': propertyNames,
      });

  @override
  Future<void> registerPushToken({
    required AttriaxPushTokenProvider provider,
    String? token,
    Map<String, Object?>? metadata,
  }) async {
    // The C-ABI splits push registration by provider.
    final method = provider.wireValue == 'apns'
        ? 'registerApplePushToken'
        : 'registerFirebaseMessagingToken';
    await _invokeVoid(method, <String, Object?>{
      'token': token,
      'metadata': metadata,
    });
  }

  // ---------------------------------------------------------------------------
  // Deep links.
  // ---------------------------------------------------------------------------

  @override
  Future<void> handleIncomingLink(
    String uri, {
    bool isInitialLink = false,
  }) async => _invokeVoid('handleIncomingLink', <String, Object?>{
    'uri': uri,
    'isInitialLink': isInitialLink,
  });

  /// Degraded: the desktop engine resolves the launch link itself, so there is
  /// no absent initial-link probe to complete. No-op.
  @override
  Future<void> completeInitialDeepLink() async {}

  @override
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    final result = _tryDispatchMap('recordDeepLink', <String, Object?>{
      'uri': uri.toString(),
      'metadata': metadata,
      'source': source,
    });
    return _deepLinkEventFromMap(result);
  }

  /// Degraded: the C-ABI routes no blocking initial-link wait. Returns the
  /// cached launch link if the engine already resolved one.
  @override
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() async =>
      getInitialDeepLink();

  /// Degraded: the C-ABI routes no blocking resolution wait; the facade falls
  /// back to the next resolved event on [deepLinkEvents].
  @override
  Future<AttriaxDeepLinkEvent?> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) async => null;

  /// Degraded: dynamic-link creation is not routed by the desktop engine.
  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) {
    throw StateError(
      'createDynamicLink is not supported by the Attriax Linux engine.',
    );
  }

  // ---------------------------------------------------------------------------
  // Revenue receipt validation.
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) async {
    final result = _dispatchMap('validateReceipt', <String, Object?>{
      'receipt': receipt,
      'test': test,
      'provider': provider,
      'environment': environment,
      'productId': productId,
      'transactionId': transactionId,
    });
    if (result == null) {
      throw StateError('Attriax validateReceipt response was empty.');
    }
    return AttriaxRevenueReceiptValidationResult.fromJson(result);
  }

  // ---------------------------------------------------------------------------
  // Consent — GDPR.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) async => _invokeVoid('setGdprConsent', <String, Object?>{
    'analytics': analytics,
    'attribution': attribution,
    'adEvents': adEvents,
  });

  @override
  Future<void> setGdprConsentNotRequired() async =>
      _invokeVoid('setGdprConsentNotRequired');

  @override
  Future<void> resetGdprConsent() async => _invokeVoid('resetGdprConsent');

  @override
  Future<void> requestGdprDataErasure() async =>
      _invokeVoid('requestGdprDataErasure');

  @override
  Future<bool> needsGdprConsent({bool localOnly = false}) async =>
      _tryDispatchBool('needsGdprConsent', <String, Object?>{
        'localOnly': localOnly,
      });

  @override
  Future<bool> getIsWaitingForGdprConsent() async =>
      _tryDispatchBool('getIsWaitingForGdprConsent');

  // ---------------------------------------------------------------------------
  // Toggles.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setAnonymousTracking({required bool enabled}) async =>
      _invokeVoid('setAnonymousTracking', <String, Object?>{
        'enabled': enabled,
      });

  @override
  Future<void> setCcpaConsent({bool? doNotSell, String? usPrivacy}) async {
    // The C-ABI splits the CCPA election into two setters; forward each field
    // that was supplied.
    if (doNotSell != null) {
      await _invokeVoid('setDoNotSell', <String, Object?>{
        'doNotSell': doNotSell,
      });
    }
    if (usPrivacy != null) {
      await _invokeVoid('setUsPrivacy', <String, Object?>{
        'usPrivacy': usPrivacy,
      });
    }
  }

  @override
  Future<void> setSdkEnabled({required bool enabled}) async =>
      _invokeVoid('setEnabled', <String, Object?>{'enabled': enabled});

  /// Degraded: the C-ABI exposes only the whole-SDK `enabled` toggle, not the
  /// separate tracking-enabled flag. No-op.
  @override
  Future<void> setEventTrackingEnabled({required bool enabled}) async {}

  // ---------------------------------------------------------------------------
  // Apple seams — forwarded for fidelity but inert on the desktop engine.
  // ---------------------------------------------------------------------------

  @override
  Future<void> submitAsaToken(String token) async =>
      _invokeVoid('submitAsaToken', <String, Object?>{'token': token});

  @override
  Future<void> setTrackingAuthorizationStatus(
    AttriaxTrackingAuthorizationStatus status,
  ) async => _invokeVoid('setAttStatus', <String, Object?>{
    'status': _trackingAuthorizationStatusToWire(status),
  });

  // ---------------------------------------------------------------------------
  // Engine reads.
  // ---------------------------------------------------------------------------

  @override
  Future<String?> getDeviceId() async => _tryDispatchString('getDeviceId');

  @override
  Future<bool> getIsFirstLaunch() async =>
      _tryDispatchBool('getIsFirstLaunch');

  @override
  Future<bool> getIsInitialized() async =>
      _tryDispatchBool('getIsInitialized');

  @override
  Future<AttriaxSdkSnapshot?> getSdkSnapshot() async {
    final result = _tryDispatchMap('getSdkSnapshot');
    return result == null ? null : AttriaxSdkSnapshot.fromPayload(result);
  }

  @override
  Future<bool> getSdkEnabled() async => _tryDispatchBool('getEnabled');

  /// Degraded: the C-ABI exposes only the whole-SDK `enabled` flag. Reports the
  /// base default (enabled).
  @override
  Future<bool> getEventTrackingEnabled() async => true;

  @override
  Future<bool> getAnonymousTracking() async =>
      _tryDispatchBool('getAnonymousTracking');

  @override
  Future<AttriaxSynchronizationState> getSynchronizationState() async {
    final wire = _tryDispatchValue('getSynchronizationState');
    return _synchronizationStateFromWire(wire);
  }

  @override
  Future<bool> getIsSynchronized() async =>
      _tryDispatchBool('getIsSynchronized');

  @override
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
  }) async => _installReferrerDetails('getOriginalInstallReferrer', timeout);

  @override
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
  }) async => _installReferrerDetails('getReinstallReferrer', timeout);

  @override
  Future<String?> getRawInstallReferrer({Duration? timeout}) async =>
      _tryDispatchString('getRawInstallReferrer', _timeoutArgs(timeout));

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
  }) async => _deepLinkReferrerDetails('getSessionReferrer', timeout);

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
  }) async => _deepLinkReferrerDetails('getLatestDeepLinkReferrer', timeout);

  @override
  Future<AttriaxSkanState?> getSkanState() async {
    final result = _tryDispatchMap('getSkanState');
    return result == null ? null : AttriaxSkanState.fromPayload(result);
  }

  @override
  Future<AttriaxDeepLinkEvent?> getLatestDeepLink() async =>
      _deepLinkEventFromMap(_tryDispatchMap('getLatestDeepLink'));

  @override
  Future<AttriaxDeepLinkEvent?> getInitialDeepLink() async =>
      _deepLinkEventFromMap(_tryDispatchMap('getInitialDeepLink'));

  @override
  Future<AttriaxRawDeepLinkEvent?> getRawInitialDeepLink() async {
    final result = _tryDispatchMap('getRawInitialDeepLink');
    if (result == null) {
      return null;
    }
    try {
      return AttriaxRawDeepLinkEvent.fromJson(result);
    } on FormatException catch (error, stackTrace) {
      _log('getRawInitialDeepLink', error, stackTrace);
      return null;
    }
  }

  @override
  Future<bool> getIsInitialDeepLinkResolved() async =>
      _tryDispatchBool('getInitialDeepLinkResolved');

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    final result = _tryDispatchMap('updateSkanConversionValue', <String, Object?>{
      'fineValue': fineValue,
      if (coarseValue != null) 'coarseValue': coarseValue.name,
      'lockWindow': lockWindow,
    });
    if (result == null) {
      return const AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.notSupported,
        message:
            'SKAdNetwork conversion updates are not supported on this platform.',
      );
    }
    return AttriaxSkanUpdateResult.fromPayload(result);
  }

  /// The desktop KMP adapter self-collects device context, so the wrapper has
  /// nothing extra to supply. Benign empty context (never throws).
  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  // ---------------------------------------------------------------------------
  // Event streams.
  // ---------------------------------------------------------------------------

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _syncController.stream;

  @override
  Stream<AttriaxDeepLinkEvent> get deepLinkEvents =>
      _deepLinkController.stream;

  // ---------------------------------------------------------------------------
  // Native event callback.
  // ---------------------------------------------------------------------------

  /// Invoked by the engine (possibly on a background thread; delivered here
  /// asynchronously through the [NativeCallable.listener] trampoline) with a
  /// NUL-terminated UTF-8 event JSON envelope.
  ///
  /// Ownership of [eventJson] is transferred to this callback by the C-ABI (the
  /// same contract as `attriax_dispatch` results): we read the bytes and then
  /// release them via `attriax_free_string`. Because `.listener` delivery is
  /// asynchronous the engine deliberately does NOT free it — freeing here is
  /// mandatory (skipping it leaks) and safe (the bytes outlive the originating
  /// call). A garbled event is dropped rather than crashing; the string is freed
  /// either way.
  void _onNativeEvent(Pointer<Utf8> eventJson, Pointer<Void> userData) {
    if (eventJson == nullptr) {
      return;
    }
    try {
      final decoded = jsonDecode(eventJson.toDartString());
      if (decoded is! Map) {
        return;
      }
      final type = decoded['type'];
      if (type == 'synchronizationState') {
        if (!_syncController.isClosed) {
          _syncController.add(
            _synchronizationStateFromWire(decoded['state']),
          );
        }
      } else if (type == 'deepLink') {
        final event = _deepLinkEventFromMap(
          _asStringKeyedMap(decoded['event']),
        );
        if (event != null && !_deepLinkController.isClosed) {
          _deepLinkController.add(event);
        }
      }
    } on Object catch (error, stackTrace) {
      _log('nativeEvent', error, stackTrace);
    } finally {
      // Ownership was transferred to us; release it (null only if the engine was
      // already disposed, in which case the process is tearing down anyway).
      _bindings?.freeString(eventJson);
    }
  }

  // ---------------------------------------------------------------------------
  // Dispatch helpers.
  // ---------------------------------------------------------------------------

  /// Core synchronous dispatch: marshals [method] + [args] to the C-ABI, parses
  /// the `{"ok":…}` envelope, frees every native string, and returns the
  /// decoded `value`. Throws [AttriaxDispatchException] on an `ok:false`
  /// envelope and [StateError] when the engine is not initialized.
  Object? _dispatch(String method, [Map<String, Object?>? args]) {
    final bindings = _bindings;
    final handle = _handle;
    if (bindings == null || handle == nullptr) {
      throw StateError('Attriax Linux engine is not initialized.');
    }

    final methodPtr = method.toNativeUtf8();
    final argsPtr = jsonEncode(args ?? const <String, Object?>{})
        .toNativeUtf8();
    Pointer<Utf8> resultPtr = nullptr;
    try {
      resultPtr = bindings.dispatch(handle, methodPtr, argsPtr);
      if (resultPtr == nullptr) {
        throw StateError('attriax_dispatch("$method") returned null.');
      }
      final decoded = jsonDecode(resultPtr.toDartString());
      if (decoded is! Map) {
        throw StateError(
          'attriax_dispatch("$method") returned a non-object envelope.',
        );
      }
      if (decoded['ok'] == true) {
        return decoded['value'];
      }
      throw AttriaxDispatchException(
        method,
        decoded['error']?.toString() ?? 'unknown_error',
      );
    } finally {
      malloc
        ..free(methodPtr)
        ..free(argsPtr);
      if (resultPtr != nullptr) {
        bindings.freeString(resultPtr);
      }
    }
  }

  /// Fire-and-forget dispatch: swallows + logs any error so a failed engine
  /// call never throws into app code (matching the other bindings).
  Future<void> _invokeVoid(String method, [Map<String, Object?>? args]) async {
    try {
      _dispatch(method, args);
    } on Object catch (error, stackTrace) {
      _log(method, error, stackTrace);
    }
  }

  Object? _tryDispatchValue(String method, [Map<String, Object?>? args]) {
    try {
      return _dispatch(method, args);
    } on Object catch (error, stackTrace) {
      _log(method, error, stackTrace);
      return null;
    }
  }

  bool _tryDispatchBool(String method, [Map<String, Object?>? args]) =>
      _tryDispatchValue(method, args) == true;

  String? _tryDispatchString(String method, [Map<String, Object?>? args]) {
    final value = _tryDispatchValue(method, args);
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  Map<String, Object?>? _tryDispatchMap(
    String method, [
    Map<String, Object?>? args,
  ]) => _asStringKeyedMap(_tryDispatchValue(method, args));

  /// Throwing map dispatch for commands whose empty result is an error.
  Map<String, Object?>? _dispatchMap(
    String method, [
    Map<String, Object?>? args,
  ]) => _asStringKeyedMap(_dispatch(method, args));

  Future<AttriaxInstallReferrerDetails?> _installReferrerDetails(
    String method,
    Duration? timeout,
  ) async {
    final result = _tryDispatchMap(method, _timeoutArgs(timeout));
    if (result == null) {
      return null;
    }
    try {
      return AttriaxInstallReferrerDetails.fromJson(result);
    } on FormatException catch (error, stackTrace) {
      _log(method, error, stackTrace);
      return null;
    }
  }

  Future<AttriaxDeepLinkReferrerDetails?> _deepLinkReferrerDetails(
    String method,
    Duration? timeout,
  ) async {
    final result = _tryDispatchMap(method, _timeoutArgs(timeout));
    if (result == null) {
      return null;
    }
    try {
      return AttriaxDeepLinkReferrerDetails.fromJson(result);
    } on FormatException catch (error, stackTrace) {
      _log(method, error, stackTrace);
      return null;
    }
  }

  Map<String, Object?>? _timeoutArgs(Duration? timeout) => timeout == null
      ? null
      : <String, Object?>{'timeoutMs': timeout.inMilliseconds};

  AttriaxDeepLinkEvent? _deepLinkEventFromMap(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    try {
      return AttriaxDeepLinkEvent.fromJson(json);
    } on FormatException catch (error, stackTrace) {
      _log('deepLinkEvent', error, stackTrace);
      return null;
    }
  }

  Map<String, Object?>? _asStringKeyedMap(Object? value) {
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(key.toString(), nestedValue),
      );
    }
    return null;
  }

  AttriaxSynchronizationState _synchronizationStateFromWire(Object? wire) =>
      switch (wire) {
        'initializing' || 'INITIALIZING' =>
          AttriaxSynchronizationState.initializing,
        'synchronizing' || 'SYNCHRONIZING' =>
          AttriaxSynchronizationState.synchronizing,
        'deferred' || 'DEFERRED' => AttriaxSynchronizationState.deferred,
        'synchronized' || 'SYNCHRONIZED' =>
          AttriaxSynchronizationState.synchronized,
        'offline' || 'OFFLINE' => AttriaxSynchronizationState.offline,
        'failed' || 'FAILED' => AttriaxSynchronizationState.failed,
        'disabled' || 'DISABLED' => AttriaxSynchronizationState.disabled,
        _ => AttriaxSynchronizationState.initializing,
      };

  String _trackingAuthorizationStatusToWire(
    AttriaxTrackingAuthorizationStatus status,
  ) => switch (status) {
    AttriaxTrackingAuthorizationStatus.notSupported => 'not_supported',
    AttriaxTrackingAuthorizationStatus.disabled => 'disabled',
    AttriaxTrackingAuthorizationStatus.notDetermined => 'not_determined',
    AttriaxTrackingAuthorizationStatus.restricted => 'restricted',
    AttriaxTrackingAuthorizationStatus.denied => 'denied',
    AttriaxTrackingAuthorizationStatus.authorized => 'authorized',
    AttriaxTrackingAuthorizationStatus.timedOut => 'timed_out',
    AttriaxTrackingAuthorizationStatus.unknown => 'unknown',
  };

  void _log(String method, Object error, StackTrace stackTrace) {
    developer.log(
      'AttriaxLinux.$method failed: ${error.runtimeType}',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Raised when the C-ABI returns an `{"ok":false,"error":…}` envelope.
class AttriaxDispatchException implements Exception {
  const AttriaxDispatchException(this.method, this.error);

  final String method;
  final String error;

  @override
  String toString() => 'AttriaxDispatchException($method): $error';
}
