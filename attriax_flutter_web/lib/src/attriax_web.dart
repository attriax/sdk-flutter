import 'dart:async';
import 'dart:developer' as developer;
import 'dart:js_interop';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'attriax_js_interop.dart';
import 'attriax_web_script_loader.dart';

/// Web implementation of [AttriaxPlatform], forwarding every engine command and
/// event to the sdk-js engine (`@attriax/js`) over `dart:js_interop`.
///
/// Under the native-engine re-wrap, Flutter-web stops running the in-Dart engine
/// and instead drives sdk-js — Attriax's reference identity implementation — so a
/// Flutter-web build produces the same wire behavior as every other platform.
/// The facade routes `kIsWeb` through [AttriaxPlatform.instance] (this class); the
/// authoritative state (identity, queue, consent, sessions, sync) lives in
/// sdk-js, so this class holds no engine logic — only the JS bridge and the
/// stream controllers that re-surface sdk-js's callbacks as Dart streams.
///
/// ## Members degraded because sdk-js genuinely lacks the capability
/// These are web-inapplicable or absent from the public sdk-js surface; each is a
/// benign no-op / default rather than a throw, matching the native bindings:
/// - [setCcpaConsent] — sdk-js has no CCPA (`doNotSell`/`usPrivacy`) surface.
///   The election is still carried in [AttriaxConfig] (ignored by sdk-js), but a
///   runtime change cannot be forwarded.
/// - [registerPushToken] — push/uninstall tokens are a mobile concept; the public
///   sdk-js API exposes no token registration.
/// - [requestGdprDataErasure] — not exposed on the public sdk-js surface.
/// - [completeInitialDeepLink] — sdk-js resolves the initial URL itself, so there
///   is nothing to signal.
/// - [getRawInstallReferrer] — there is no platform install-referrer string on
///   the web.
/// - Apple seams ([submitAsaToken], [setTrackingAuthorizationStatus], ATT/SKAN
///   reads) — not applicable on the web; they keep the base benign defaults.
class AttriaxWeb extends AttriaxPlatform {
  AttriaxWeb();

  /// Registers this class as the web implementation of `attriax_flutter`.
  static void registerWith(Registrar registrar) {
    AttriaxPlatform.instance = AttriaxWeb();
  }

  static const String _logName = 'attriax.web';

  AttriaxJsSdk? _sdk;

  final StreamController<AttriaxSynchronizationState> _syncController =
      StreamController<AttriaxSynchronizationState>.broadcast();
  final StreamController<AttriaxDeepLinkEvent> _deepLinkController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();
  final StreamController<AttriaxRawDeepLinkEvent> _rawDeepLinkController =
      StreamController<AttriaxRawDeepLinkEvent>.broadcast();
  final StreamController<AttriaxInitialDeepLinkResolution>
  _initialDeepLinkController =
      StreamController<AttriaxInitialDeepLinkResolution>.broadcast();

  final List<JSFunction> _unsubscribers = <JSFunction>[];

  // ---------------------------------------------------------------------------
  // Lifecycle.
  // ---------------------------------------------------------------------------

  @override
  Future<void> initialize(AttriaxConfig config) async {
    await ensureAttriaxJsLoaded();
    final sdk = AttriaxJsSdk(_jsObject(config.toJson()));
    _sdk = sdk;
    await sdk.init(JSObject()).toDart;
    _wireEngineStreams(sdk);
  }

  @override
  Future<void> flush() async {
    await _sdk?.flush().toDart;
  }

  @override
  Future<void> reset() async {
    await _sdk?.reset().toDart;
  }

  @override
  Future<void> dispose() async {
    for (final unsubscribe in _unsubscribers) {
      _safeInvoke(unsubscribe, 'unsubscribe');
    }
    _unsubscribers.clear();
    try {
      _sdk?.dispose();
    } on Object catch (error, stackTrace) {
      _log('dispose', error, stackTrace);
    }
    _sdk = null;
    await _syncController.close();
    await _deepLinkController.close();
    await _rawDeepLinkController.close();
    await _initialDeepLinkController.close();
  }

  // ---------------------------------------------------------------------------
  // Tracking — events / page views.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordEvent(
    String name, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) => _fireAndForget(
    'recordEvent',
    (sdk) => sdk.tracking.recordEvent(
      name,
      _jsOptions(<String, Object?>{
        'eventData': eventData,
        'flushImmediately': flushImmediately,
      }),
    ),
  );

  @override
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) => _fireAndForget(
    'recordPageView',
    (sdk) => sdk.tracking.recordPageView(
      pageName,
      _jsOptions(<String, Object?>{
        'pageClass': pageClass,
        'pageTitle': pageTitle,
        'previousPageName': previousPageName,
        'parameters': parameters,
        'source': source,
        'flushImmediately': flushImmediately,
      }),
    ),
  );

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
  }) => _fireAndForget(
    'recordPurchase',
    (sdk) => sdk.tracking.recordPurchase(
      revenue,
      _jsOptions(<String, Object?>{
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
      }),
    ),
  );

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
  }) => _fireAndForget(
    'recordRefund',
    (sdk) => sdk.tracking.recordRefund(
      revenue,
      _jsOptions(<String, Object?>{
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
      }),
    ),
  );

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
  }) => _fireAndForget(
    'recordAdRevenue',
    (sdk) => sdk.tracking.recordAdRevenue(
      revenue,
      _jsOptions(<String, Object?>{
        'currency': currency,
        'revenueInMicros': revenueInMicros,
        'adNetwork': adNetwork,
        'adFormat': adFormat,
        'adType': adType,
        'adPlacement': adPlacement,
        'test': test,
        'metadata': metadata,
        'flushImmediately': flushImmediately,
      }),
    ),
  );

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
  }) => _fireAndForget(
    'recordAdEvent',
    // The platform interface passes the reserved wire event name (`ad_request`,
    // …); sdk-js's `recordAdEvent` re-derives that name from its ad-type slug,
    // so translate back to the slug it expects.
    (sdk) => sdk.tracking.recordAdEvent(
      _adEventTypeSlug(eventName),
      _jsOptions(<String, Object?>{
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
      }),
    ),
  );

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
  }) => _fireAndForget(
    'recordNotification',
    (sdk) => sdk.tracking.recordNotification(
      type,
      notificationId,
      _jsOptions(<String, Object?>{
        'linkId': linkId,
        'campaignId': campaignId,
        'title': title,
        'source': source,
        'payload': payload,
        'metadata': metadata,
        'flushImmediately': flushImmediately,
      }),
    ),
  );

  @override
  Future<void> recordError({
    required String message,
    required String exceptionType,
    String? stackTrace,
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) => _fireAndForget('recordError', (sdk) {
    // Hand sdk-js a real `Error` instance so its `error instanceof Error`
    // fast-path emits clean `exceptionType`/`message`/`stackTrace` fields
    // without wrapping the value and attaching a `rawError` metadata blob.
    final error = JsError(message)..name = exceptionType;
    if (stackTrace != null) {
      error.stack = stackTrace;
    }
    return sdk.tracking.recordError(
      error,
      _jsOptions(<String, Object?>{
        'source': source,
        'isFatal': fatal,
        'reason': reason,
        'metadata': metadata,
      }),
    );
  });

  // ---------------------------------------------------------------------------
  // Tracking — identify / user properties.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setUser({String? userId, String? userName}) => _fireAndForget(
    'setUser',
    (sdk) => sdk.tracking.setUser(
      userId,
      _jsOptions(<String, Object?>{'userName': userName}),
    ),
  );

  @override
  Future<void> setUserProperty(String name, Object? value) => _fireAndForget(
    'setUserProperty',
    (sdk) => sdk.tracking.setUserProperty(name, value.jsify()),
  );

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) =>
      _fireAndForget(
        'setUserProperties',
        (sdk) => sdk.tracking.setUserProperties(_jsObject(properties)),
      );

  @override
  Future<void> clearUserProperties({List<String>? propertyNames}) =>
      _fireAndForget('clearUserProperties', (sdk) {
        final names = <JSString>[
          for (final name in propertyNames ?? const <String>[]) name.toJS,
        ].toJS;
        return sdk.tracking.clearUserProperties(names);
      });

  /// Degraded: push/uninstall tokens are a mobile concept; the public sdk-js
  /// surface exposes no token registration. No-op on the web.
  @override
  Future<void> registerPushToken({
    required AttriaxPushTokenProvider provider,
    String? token,
    Map<String, Object?>? metadata,
  }) async {}

  // ---------------------------------------------------------------------------
  // Deep links.
  // ---------------------------------------------------------------------------

  @override
  Future<void> handleIncomingLink(String uri, {bool isInitialLink = false}) =>
      _fireAndForget(
        'handleIncomingLink',
        (sdk) => sdk.deepLinks.recordDeepLink(
          _jsObject(<String, Object?>{
            'uri': uri,
            'isInitialLink': isInitialLink,
          }),
        ),
      );

  /// Degraded: sdk-js resolves the launch URL itself, so there is no absent
  /// initial-link probe to complete. No-op.
  @override
  Future<void> completeInitialDeepLink() async {}

  @override
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    final sdk = _sdk;
    if (sdk == null) {
      return null;
    }
    try {
      final result = await sdk.deepLinks
          .recordDeepLink(
            _jsOptions(<String, Object?>{
              'uri': uri.toString(),
              'metadata': metadata,
              'source': source,
            }),
          )
          .toDart;
      return _deepLinkEventFromJs(result);
    } on Object catch (error, stackTrace) {
      _log('recordDeepLink', error, stackTrace);
      return null;
    }
  }

  @override
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() async {
    final sdk = _sdk;
    if (sdk == null) {
      return null;
    }
    try {
      final result = await sdk.deepLinks.waitForInitialDeepLink().toDart;
      return _deepLinkEventFromJs(result);
    } on Object catch (error, stackTrace) {
      _log('waitForInitialDeepLink', error, stackTrace);
      return null;
    }
  }

  @override
  Future<AttriaxDeepLinkEvent?> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) async {
    final sdk = _sdk;
    if (sdk == null) {
      return null;
    }
    try {
      final result = await sdk.deepLinks
          .waitResolution(_jsObject(rawEvent.toJson()))
          .toDart;
      return _deepLinkEventFromJs(result);
    } on Object catch (error, stackTrace) {
      _log('waitForDeepLinkResolution', error, stackTrace);
      return null;
    }
  }

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
  }) async {
    final sdk = _sdk;
    if (sdk == null) {
      throw StateError('Attriax web engine is not initialized.');
    }
    final options = _jsOptions(<String, Object?>{
      'name': name,
      'destinationUrl': destinationUrl,
      'group': group,
      'prefix': prefix,
      if (socialPreview != null)
        'socialPreview': <String, Object?>{
          'title': socialPreview.title,
          'description': socialPreview.description,
        },
      if (utms != null)
        'utms': <String, Object?>{
          'source': utms.source,
          'medium': utms.medium,
          'campaign': utms.campaign,
          'term': utms.term,
          'content': utms.content,
        },
      if (redirects != null)
        'redirects': <String, Object?>{
          'ios': redirects.ios,
          'android': redirects.android,
        },
      'data': data,
    });
    final result = await sdk.deepLinks.createDynamicLink(options).toDart;
    final json = _coerceMap(result.dartify());
    if (json == null) {
      throw StateError('Attriax createDynamicLink response was empty.');
    }
    return AttriaxCreateDynamicLinkResult.fromJson(json);
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
    final sdk = _sdk;
    if (sdk == null) {
      throw StateError('Attriax web engine is not initialized.');
    }
    final result = await sdk
        .validateReceipt(
          _jsOptions(<String, Object?>{
            'receipt': receipt,
            'test': test,
            'provider': provider,
            'environment': environment,
            'productId': productId,
            'transactionId': transactionId,
          }),
        )
        .toDart;
    final json = _coerceMap(result.dartify());
    if (json == null) {
      throw StateError('Attriax validateReceipt response was empty.');
    }
    return AttriaxRevenueReceiptValidationResult.fromJson(json);
  }

  // ---------------------------------------------------------------------------
  // Consent — GDPR.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) async {
    _runVoid('setGdprConsent', (sdk) {
      sdk.consent.gdpr.setConsent(
        _jsObject(<String, Object?>{
          'analytics': analytics,
          'attribution': attribution,
          'adEvents': adEvents,
        }),
      );
    });
  }

  @override
  Future<void> setGdprConsentNotRequired() async {
    _runVoid('setGdprConsentNotRequired', (sdk) {
      sdk.consent.gdpr.setNotRequired();
    });
  }

  @override
  Future<void> resetGdprConsent() async {
    _runVoid('resetGdprConsent', (sdk) {
      sdk.consent.gdpr.reset();
    });
  }

  /// Degraded: GDPR data erasure is not exposed on the public sdk-js surface.
  @override
  Future<void> requestGdprDataErasure() async {}

  @override
  Future<bool> needsGdprConsent({bool localOnly = false}) async {
    final sdk = _sdk;
    if (sdk == null) {
      return false;
    }
    try {
      final result = await sdk.consent.gdpr
          .needsConsent(_jsObject(<String, Object?>{'localOnly': localOnly}))
          .toDart;
      return result.toDart;
    } on Object catch (error, stackTrace) {
      _log('needsGdprConsent', error, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> getIsWaitingForGdprConsent() async =>
      _sdk?.consent.gdpr.isWaitingForConsent ?? false;

  // ---------------------------------------------------------------------------
  // Toggles.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setAnonymousTracking({required bool enabled}) async {
    _runVoid('setAnonymousTracking', (sdk) {
      sdk.tracking.anonymousTrackingEnabled = enabled;
    });
  }

  /// Degraded: sdk-js has no CCPA (`doNotSell`/`usPrivacy`) surface. The election
  /// is carried on [AttriaxConfig] at construction (ignored by sdk-js); a runtime
  /// change cannot be forwarded. No-op.
  @override
  Future<void> setCcpaConsent({bool? doNotSell, String? usPrivacy}) async {}

  @override
  Future<void> setSdkEnabled({required bool enabled}) async {
    _runVoid('setSdkEnabled', (sdk) {
      sdk.enabled = enabled;
    });
  }

  @override
  Future<void> setEventTrackingEnabled({required bool enabled}) async {
    _runVoid('setEventTrackingEnabled', (sdk) {
      sdk.tracking.enabled = enabled;
    });
  }

  // ---------------------------------------------------------------------------
  // Apple seams — not applicable on the web (base defaults / no-ops).
  // ---------------------------------------------------------------------------

  /// Degraded: Apple Search Ads is iOS-only. No-op.
  @override
  Future<void> submitAsaToken(String token) async {}

  /// Degraded: App Tracking Transparency is iOS-only. No-op.
  @override
  Future<void> setTrackingAuthorizationStatus(
    AttriaxTrackingAuthorizationStatus status,
  ) async {}

  // ---------------------------------------------------------------------------
  // Engine reads.
  // ---------------------------------------------------------------------------

  @override
  Future<String?> getDeviceId() async => _sdk?.deviceId;

  @override
  Future<bool> getIsFirstLaunch() async => _sdk?.isFirstLaunch ?? false;

  @override
  Future<bool> getIsInitialized() async => _sdk?.isInitialized ?? false;

  @override
  Future<AttriaxSdkSnapshot?> getSdkSnapshot() async {
    final json = _coerceMap(_sdk?.sdkSnapshot.dartify());
    return json == null ? null : AttriaxSdkSnapshot.fromPayload(json);
  }

  @override
  Future<bool> getSdkEnabled() async => _sdk?.enabled ?? false;

  @override
  Future<bool> getEventTrackingEnabled() async =>
      _sdk?.tracking.enabled ?? true;

  @override
  Future<bool> getAnonymousTracking() async =>
      _sdk?.tracking.anonymousTrackingEnabled ?? true;

  @override
  Future<AttriaxSynchronizationState> getSynchronizationState() async {
    final sdk = _sdk;
    if (sdk == null) {
      return AttriaxSynchronizationState.initializing;
    }
    return _synchronizationStateFromWire(sdk.synchronization.state);
  }

  @override
  Future<bool> getIsSynchronized() async =>
      _sdk?.synchronization.isSynchronized ?? false;

  @override
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
  }) => _installReferrer(
    'getOriginalInstallReferrer',
    (sdk) => sdk.referrer.getOriginalInstallReferrer(),
  );

  @override
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
  }) => _installReferrer(
    'getReinstallReferrer',
    (sdk) => sdk.referrer.getReinstallReferrer(),
  );

  /// Degraded: there is no platform install-referrer string on the web.
  @override
  Future<String?> getRawInstallReferrer({Duration? timeout}) async => null;

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
  }) => _deepLinkReferrer(
    'getSessionReferrer',
    (sdk) => sdk.referrer.getSessionReferrer(),
  );

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
  }) => _deepLinkReferrer(
    'getLatestDeepLinkReferrer',
    (sdk) => sdk.referrer.getLatestDeepLinkReferrer(),
  );

  /// Degraded: SKAdNetwork is iOS-only.
  @override
  Future<AttriaxSkanState?> getSkanState() async => null;

  @override
  Future<AttriaxDeepLinkEvent?> getLatestDeepLink() async =>
      _deepLinkEventFromJs(_sdk?.deepLinks.latestDeepLink);

  @override
  Future<AttriaxDeepLinkEvent?> getInitialDeepLink() async =>
      _deepLinkEventFromJs(_sdk?.deepLinks.initialDeepLink);

  @override
  Future<AttriaxRawDeepLinkEvent?> getRawInitialDeepLink() async =>
      _rawDeepLinkEventFromJs(_sdk?.deepLinks.rawInitialDeepLink);

  @override
  Future<bool> getIsInitialDeepLinkResolved() async =>
      _sdk?.deepLinks.initialDeepLinkResolved ?? false;

  // ---------------------------------------------------------------------------
  // Event streams.
  // ---------------------------------------------------------------------------

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _syncController.stream;

  @override
  Stream<AttriaxDeepLinkEvent> get deepLinkEvents => _deepLinkController.stream;

  @override
  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinkEvents =>
      _rawDeepLinkController.stream;

  @override
  Stream<AttriaxInitialDeepLinkResolution> get initialDeepLinkResolutions =>
      _initialDeepLinkController.stream;

  // ---------------------------------------------------------------------------
  // Engine → Dart stream bridging.
  // ---------------------------------------------------------------------------

  void _wireEngineStreams(AttriaxJsSdk sdk) {
    _unsubscribers
      ..add(
        sdk.synchronization.subscribe(
          (JSString state) {
            if (!_syncController.isClosed) {
              _syncController.add(_synchronizationStateFromWire(state.toDart));
            }
          }.toJS,
        ),
      )
      ..add(
        sdk.deepLinks.stream.subscribe(
          (JSObject event) {
            final parsed = _deepLinkEventFromJs(event);
            if (parsed != null && !_deepLinkController.isClosed) {
              _deepLinkController.add(parsed);
            }
          }.toJS,
        ),
      )
      ..add(
        sdk.deepLinks.rawStream.subscribe(
          (JSObject event) {
            final parsed = _rawDeepLinkEventFromJs(event);
            if (parsed != null && !_rawDeepLinkController.isClosed) {
              _rawDeepLinkController.add(parsed);
            }
          }.toJS,
        ),
      );

    // sdk-js has no discrete initial-link-resolution stream; synthesize a single
    // resolution once the launch-URL probe settles so the facade's
    // `waitForInitialDeepLink` completer is released, mirroring the native
    // bindings' `attriax/events/initial_deep_link` channel.
    unawaited(_emitInitialDeepLinkResolution(sdk));
  }

  Future<void> _emitInitialDeepLinkResolution(AttriaxJsSdk sdk) async {
    try {
      final result = await sdk.deepLinks.waitForInitialDeepLink().toDart;
      if (_initialDeepLinkController.isClosed) {
        return;
      }
      _initialDeepLinkController.add(
        AttriaxInitialDeepLinkResolution(
          resolved: true,
          deepLink: _deepLinkEventFromJs(result),
        ),
      );
    } on Object catch (error, stackTrace) {
      _log('waitForInitialDeepLink', error, stackTrace);
      if (!_initialDeepLinkController.isClosed) {
        _initialDeepLinkController.add(
          const AttriaxInitialDeepLinkResolution(resolved: true),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Invocation + conversion helpers.
  // ---------------------------------------------------------------------------

  /// Awaits a sdk-js command; swallows + logs errors so a failed engine call
  /// never throws into app code (matching the MethodChannel binding).
  Future<void> _fireAndForget(
    String method,
    JSPromise<JSAny?> Function(AttriaxJsSdk sdk) command,
  ) async {
    final sdk = _sdk;
    if (sdk == null) {
      return;
    }
    try {
      await command(sdk).toDart;
    } on Object catch (error, stackTrace) {
      _log(method, error, stackTrace);
    }
  }

  /// Runs a synchronous sdk-js setter/command, swallowing + logging errors.
  void _runVoid(String method, void Function(AttriaxJsSdk sdk) command) {
    final sdk = _sdk;
    if (sdk == null) {
      return;
    }
    try {
      command(sdk);
    } on Object catch (error, stackTrace) {
      _log(method, error, stackTrace);
    }
  }

  void _safeInvoke(JSFunction fn, String label) {
    try {
      fn.callAsFunction();
    } on Object catch (error, stackTrace) {
      _log(label, error, stackTrace);
    }
  }

  Future<AttriaxInstallReferrerDetails?> _installReferrer(
    String method,
    JSPromise<JSObject?> Function(AttriaxJsSdk sdk) reader,
  ) async {
    final sdk = _sdk;
    if (sdk == null) {
      return null;
    }
    try {
      final json = _coerceMap((await reader(sdk).toDart).dartify());
      return json == null ? null : AttriaxInstallReferrerDetails.fromJson(json);
    } on Object catch (error, stackTrace) {
      _log(method, error, stackTrace);
      return null;
    }
  }

  Future<AttriaxDeepLinkReferrerDetails?> _deepLinkReferrer(
    String method,
    JSPromise<JSObject?> Function(AttriaxJsSdk sdk) reader,
  ) async {
    final sdk = _sdk;
    if (sdk == null) {
      return null;
    }
    try {
      final json = _coerceMap((await reader(sdk).toDart).dartify());
      return json == null
          ? null
          : AttriaxDeepLinkReferrerDetails.fromJson(json);
    } on Object catch (error, stackTrace) {
      _log(method, error, stackTrace);
      return null;
    }
  }

  AttriaxDeepLinkEvent? _deepLinkEventFromJs(JSObject? value) {
    final json = _coerceMap(value.dartify());
    if (json == null) {
      return null;
    }
    try {
      return AttriaxDeepLinkEvent.fromJson(json);
    } on Object catch (error, stackTrace) {
      _log('deepLinkEvent', error, stackTrace);
      return null;
    }
  }

  AttriaxRawDeepLinkEvent? _rawDeepLinkEventFromJs(JSObject? value) {
    final json = _coerceMap(value.dartify());
    if (json == null) {
      return null;
    }
    try {
      return AttriaxRawDeepLinkEvent.fromJson(json);
    } on Object catch (error, stackTrace) {
      _log('rawDeepLinkEvent', error, stackTrace);
      return null;
    }
  }

  /// Builds a JS object from [map] with all entries preserved.
  JSObject _jsObject(Map<String, Object?> map) => map.jsify()! as JSObject;

  /// Builds a JS options object, dropping top-level `null` entries so sdk-js sees
  /// `undefined` (an omitted optional) rather than an explicit `null`.
  JSObject _jsOptions(Map<String, Object?> map) {
    final filtered = <String, Object?>{
      for (final entry in map.entries)
        if (entry.value != null) entry.key: entry.value,
    };
    return filtered.jsify()! as JSObject;
  }

  Map<String, Object?>? _coerceMap(Object? value) {
    if (value is Map) {
      return value.map((key, nested) => MapEntry(key.toString(), nested));
    }
    return null;
  }

  String _adEventTypeSlug(String eventName) =>
      _adEventTypeSlugByEventName[eventName] ??
      (eventName.startsWith('ad_') ? eventName.substring(3) : eventName);

  AttriaxSynchronizationState _synchronizationStateFromWire(String wire) =>
      switch (wire) {
        'initializing' => AttriaxSynchronizationState.initializing,
        'synchronizing' => AttriaxSynchronizationState.synchronizing,
        'deferred' => AttriaxSynchronizationState.deferred,
        'synchronized' => AttriaxSynchronizationState.synchronized,
        'offline' => AttriaxSynchronizationState.offline,
        'failed' => AttriaxSynchronizationState.failed,
        'disabled' => AttriaxSynchronizationState.disabled,
        _ => AttriaxSynchronizationState.initializing,
      };

  void _log(String method, Object error, StackTrace stackTrace) {
    developer.log(
      'AttriaxWeb.$method failed: ${error.runtimeType}',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

const Map<String, String> _adEventTypeSlugByEventName = <String, String>{
  'ad_request': 'request',
  'ad_load': 'load',
  'ad_load_failed': 'load_failed',
  'ad_show': 'show',
  'ad_show_failed': 'show_failed',
  'ad_impression': 'impression',
  'ad_click': 'click',
  'ad_dismiss': 'dismiss',
  'ad_reward': 'reward',
};
