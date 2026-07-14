import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import '../attriax_consent.dart';
import '../attriax_notification_event.dart';
import 'attriax_deep_link_listener.dart';
import 'attriax_logger.dart';
import 'attriax_runtime_interface.dart';

/// [AttriaxRuntimeInterface] backed by a native engine via
/// `attriax_flutter_platform_interface`.
///
/// This is the facade seam for platforms whose engine lives in native code
/// (iOS/macOS run the KMP core through the `AttriaxCore` XCFramework and the
/// Swift plugin). Every command forwards to [AttriaxPlatform.instance]; the
/// authoritative state (identity, queue, consent, sessions, sync) lives in the
/// native engine, so this class holds no engine logic — only the small caches
/// the facade's *synchronous* getters need, seeded on [init] and kept fresh from
/// the engine's event streams.
///
/// The native command surface is a superset-in-progress: the core path
/// (initialize / tracking / consent / SKAN / ASA / toggles / core reads / sync +
/// deep-link event streams) is live, while richer *reads* (referrer getters,
/// dynamic links, receipt validation, ATT request) may still be unimplemented on
/// a given binding. Those are called defensively — an unimplemented platform
/// method degrades to the same benign default the pure-Dart engine would return
/// rather than throwing into app code.
///
/// Known limitation: the platform interface does not (yet) expose GDPR consent
/// *reader* state, so [gdprConsentState] / [gdprConsentValues] are tracked
/// locally from the app's own `setGdprConsent*` calls. They therefore reflect
/// this process's decisions but not a native-restored decision from a prior
/// launch. `isWaitingForGdprConsent` is seeded from the engine.
class AttriaxNativeRuntime implements AttriaxRuntimeInterface {
  AttriaxNativeRuntime({
    required this.config,
    required AttriaxLogger logger,
    AttriaxDeepLinkListener? deepLinkListener,
  }) : _logger = logger,
       _deepLinkListener = deepLinkListener {
    _anonymousTracking = config.anonymousTracking;
    _ccpaDoNotSell = config.doNotSell;
    _ccpaUsPrivacy = config.usPrivacy;
  }

  final AttriaxConfig config;
  final AttriaxLogger _logger;
  final AttriaxDeepLinkListener? _deepLinkListener;

  AttriaxPlatform get _platform => AttriaxPlatform.instance;

  // --- broadcast event controllers (bridged from the native streams) ---
  final StreamController<AttriaxSynchronizationState> _syncController =
      StreamController<AttriaxSynchronizationState>.broadcast();
  final StreamController<AttriaxDeepLinkEvent> _deepLinkController =
      StreamController<AttriaxDeepLinkEvent>.broadcast();
  final StreamController<AttriaxRawDeepLinkEvent> _rawDeepLinkController =
      StreamController<AttriaxRawDeepLinkEvent>.broadcast();

  StreamSubscription<AttriaxSynchronizationState>? _syncSub;
  StreamSubscription<AttriaxDeepLinkEvent>? _deepLinkSub;
  StreamSubscription<AttriaxRawDeepLinkEvent>? _rawDeepLinkSub;
  StreamSubscription<AttriaxInitialDeepLinkResolution>? _initialLinkSub;

  final Completer<void> _initialLinkProbe = Completer<void>();

  // --- cached synchronous state ---
  bool _initialized = false;
  bool _sdkEnabled = true;
  bool _eventsEnabled = true;
  bool _anonymousTracking = true;
  bool _isFirstLaunch = false;
  String? _deviceId;
  AttriaxSdkSnapshot? _sdkSnapshot;
  AttriaxSynchronizationState _synchronizationState =
      AttriaxSynchronizationState.initializing;
  AttriaxSkanState? _skanState;
  AttriaxDeepLinkEvent? _latestDeepLink;
  AttriaxDeepLinkEvent? _initialDeepLink;
  AttriaxRawDeepLinkEvent? _rawInitialDeepLink;
  bool _initialDeepLinkResolved = false;
  AttriaxGdprConsentState _gdprConsentState = AttriaxGdprConsentState.unknown;
  AttriaxGdprConsentValues? _gdprConsentValues;
  bool _isWaitingForGdprConsent = false;

  // CCPA election, seeded from config and overridable at runtime. Held in
  // memory: the authoritative latch lives server-side, the native engine only
  // reports the current value, so these caches back the `consent.ccpa` getters.
  bool? _ccpaDoNotSell;
  String? _ccpaUsPrivacy;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> init() async {
    await _platform.initialize(config);
    _initialized = true;
    _subscribeToNativeStreams();
    await _seedCachedState();
    await _startDeepLinkForwarding();
  }

  @override
  Future<void> reset() async {
    await _platform.reset();
    _initialized = false;
    _deviceId = null;
    _sdkSnapshot = null;
    _latestDeepLink = null;
    _initialDeepLink = null;
    _rawInitialDeepLink = null;
    _initialDeepLinkResolved = false;
    _synchronizationState = AttriaxSynchronizationState.initializing;
    _gdprConsentState = AttriaxGdprConsentState.unknown;
    _gdprConsentValues = null;
    _ccpaDoNotSell = config.doNotSell;
    _ccpaUsPrivacy = config.usPrivacy;
  }

  @override
  Future<void> flush() => _fireAndForget(() => _platform.flush(), 'flush');

  @override
  Future<void> dispose() async {
    await _deepLinkListener?.stop();
    await _syncSub?.cancel();
    await _deepLinkSub?.cancel();
    await _rawDeepLinkSub?.cancel();
    await _initialLinkSub?.cancel();
    await _syncController.close();
    await _deepLinkController.close();
    await _rawDeepLinkController.close();
    await _fireAndForget(() => _platform.dispose(), 'dispose');
  }

  void _subscribeToNativeStreams() {
    _syncSub ??= _platform.synchronizationStates.listen((state) {
      _synchronizationState = state;
      if (!_syncController.isClosed) {
        _syncController.add(state);
      }
    }, onError: (Object e) => _logger.warning('sync stream error', error: e));

    _deepLinkSub ??= _platform.deepLinkEvents.listen(
      (event) {
        _latestDeepLink = event;
        if (!_deepLinkController.isClosed) {
          _deepLinkController.add(event);
        }
      },
      onError: (Object e) =>
          _logger.warning('deep-link stream error', error: e),
    );

    _rawDeepLinkSub ??= _platform.rawDeepLinkEvents.listen(
      (event) {
        // The first raw event of the session is the launch (cold-start) link;
        // cache it so the `rawInitialDeepLink` getter can surface it. `??=` keeps
        // only the first, mirroring how `_initialDeepLink` captures the launch
        // link from the initial-resolution stream.
        _rawInitialDeepLink ??= event;
        if (!_rawDeepLinkController.isClosed) {
          _rawDeepLinkController.add(event);
        }
      },
      onError: (Object e) =>
          _logger.warning('raw deep-link stream error', error: e),
    );

    _initialLinkSub ??= _platform.initialDeepLinkResolutions.listen(
      (res) {
        _initialDeepLinkResolved = res.resolved;
        if (res.deepLink != null) {
          _initialDeepLink = res.deepLink;
        }
        if (!_initialLinkProbe.isCompleted) {
          _initialLinkProbe.complete();
        }
      },
      onError: (Object e) =>
          _logger.warning('initial deep-link stream error', error: e),
    );
  }

  Future<void> _seedCachedState() async {
    _deviceId = await _readOr(() => _platform.getDeviceId(), _deviceId);
    _isFirstLaunch = await _readOr(
      () => _platform.getIsFirstLaunch(),
      _isFirstLaunch,
    );
    _sdkSnapshot = await _readOr(
      () => _platform.getSdkSnapshot(),
      _sdkSnapshot,
    );
    _sdkEnabled = await _readOr(() => _platform.getSdkEnabled(), _sdkEnabled);
    _eventsEnabled = await _readOr(
      () => _platform.getEventTrackingEnabled(),
      _eventsEnabled,
    );
    _anonymousTracking = await _readOr(
      () => _platform.getAnonymousTracking(),
      _anonymousTracking,
    );
    _skanState = await _readOr(() => _platform.getSkanState(), _skanState);
    // Seed the raw launch link from the engine snapshot when the binding serves
    // it (bindings that only stream raw links fall through to the stream capture
    // in `_subscribeToNativeStreams`). Don't clobber a value the stream already
    // cached before this seed ran.
    _rawInitialDeepLink ??= await _readOr(
      () => _platform.getRawInitialDeepLink(),
      _rawInitialDeepLink,
    );
    _isWaitingForGdprConsent = await _readOr(
      () => _platform.getIsWaitingForGdprConsent(),
      _isWaitingForGdprConsent,
    );
    final synced = await _readOr(() => _platform.getIsSynchronized(), false);
    if (synced) {
      _synchronizationState = AttriaxSynchronizationState.synchronized;
    }
  }

  Future<void> _startDeepLinkForwarding() async {
    final listener = _deepLinkListener;
    if (listener == null) {
      return;
    }
    await listener.start(
      (uri, {required bool isInitialLink}) => _fireAndForget(
        () => _platform.handleIncomingLink(
          uri.toString(),
          isInitialLink: isInitialLink,
        ),
        'handleIncomingLink',
      ),
      onInitialLinkProbeCompleted: () => _fireAndForget(
        () => _platform.completeInitialDeepLink(),
        'completeInitialDeepLink',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Synchronous getters (served from cache)
  // ---------------------------------------------------------------------------

  @override
  bool get isInitialized => _initialized;
  @override
  bool get isEnabled => _sdkEnabled;
  @override
  bool get areEventsEnabled => _eventsEnabled;
  @override
  bool get anonymousTrackingEnabled => _anonymousTracking;
  @override
  bool get isFirstLaunch => _isFirstLaunch;
  @override
  String? get deviceId => _deviceId;
  @override
  AttriaxSdkSnapshot? get sdkSnapshot => _sdkSnapshot;
  @override
  AttriaxGdprConsentState get gdprConsentState => _gdprConsentState;
  @override
  AttriaxGdprConsentValues? get gdprConsentValues => _gdprConsentValues;
  @override
  bool get isWaitingForGdprConsent => _isWaitingForGdprConsent;
  @override
  bool get isSynchronized =>
      _synchronizationState == AttriaxSynchronizationState.synchronized;
  @override
  AttriaxSynchronizationState get synchronizationState => _synchronizationState;
  @override
  AttriaxSkanState? get skanState => _skanState;
  @override
  AttriaxDeepLinkEvent? get initialDeepLink => _initialDeepLink;
  @override
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink => _rawInitialDeepLink;
  @override
  bool get isInitialDeepLinkResolved => _initialDeepLinkResolved;
  @override
  AttriaxDeepLinkEvent? get latestDeepLink => _latestDeepLink;

  // ---------------------------------------------------------------------------
  // Event streams
  // ---------------------------------------------------------------------------

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _syncController.stream;
  @override
  Stream<AttriaxDeepLinkEvent> get deepLinks => _deepLinkController.stream;
  @override
  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinks =>
      _rawDeepLinkController.stream;

  // ---------------------------------------------------------------------------
  // Tracking
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) => _platform.recordEvent(
    eventName,
    eventData: eventData,
    flushImmediately: flushImmediately,
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
  }) => _platform.recordPageView(
    pageName,
    pageClass: pageClass,
    pageTitle: pageTitle,
    previousPageName: previousPageName,
    parameters: parameters,
    source: source,
    flushImmediately: flushImmediately,
  );

  @override
  Future<void> recordNotification({
    required AttriaxNotificationEventType type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) => _platform.recordNotification(
    type: type.value,
    notificationId: notificationId,
    linkId: linkId,
    campaignId: campaignId,
    title: title,
    source: source?.value,
    metadata: metadata,
    flushImmediately: flushImmediately,
  );

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) => _platform.recordError(
    message: error.toString(),
    exceptionType: error.runtimeType.toString(),
    stackTrace: stackTrace.toString(),
    fatal: fatal,
    source: _trimOrNull(source) ?? 'manual',
    reason: _trimOrNull(reason),
    metadata: metadata,
  );

  @override
  Future<void> setUser(String? userId, {String? userName}) =>
      _platform.setUser(userId: userId, userName: userName);

  @override
  Future<void> setUserProperty(String name, Object? value) =>
      _platform.setUserProperty(name, value);

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) =>
      _platform.setUserProperties(properties);

  @override
  Future<void> clearUserProperties({List<String>? propertyNames}) =>
      _platform.clearUserProperties(propertyNames: propertyNames);

  @override
  Future<void> registerFirebaseMessagingToken({
    required String? token,
    Map<String, Object?>? metadata,
  }) => _platform.registerPushToken(
    provider: AttriaxPushTokenProvider.fcm,
    token: token,
    metadata: metadata,
  );

  @override
  Future<void> registerApplePushToken({
    required String? token,
    Map<String, Object?>? metadata,
  }) => _platform.registerPushToken(
    provider: AttriaxPushTokenProvider.apns,
    token: token,
    metadata: metadata,
  );

  // ---------------------------------------------------------------------------
  // Toggles (fire-and-forget; cache flips immediately)
  // ---------------------------------------------------------------------------

  @override
  void setEnabled({required bool enabled}) {
    _sdkEnabled = enabled;
    unawaited(
      _fireAndForget(
        () => _platform.setSdkEnabled(enabled: enabled),
        'setSdkEnabled',
      ),
    );
  }

  @override
  void setEventsEnabled({required bool enabled}) {
    _eventsEnabled = enabled;
    unawaited(
      _fireAndForget(
        () => _platform.setEventTrackingEnabled(enabled: enabled),
        'setEventTrackingEnabled',
      ),
    );
  }

  @override
  void setAnonymousTrackingEnabled({required bool enabled}) {
    _anonymousTracking = enabled;
    unawaited(
      _fireAndForget(
        () => _platform.setAnonymousTracking(enabled: enabled),
        'setAnonymousTracking',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Consent
  // ---------------------------------------------------------------------------

  @override
  void setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) {
    _gdprConsentState = AttriaxGdprConsentState.granted;
    _gdprConsentValues = AttriaxGdprConsentValues(
      analytics: analytics,
      attribution: attribution,
      adEvents: adEvents,
    );
    _isWaitingForGdprConsent = false;
    unawaited(
      _fireAndForget(
        () => _platform.setGdprConsent(
          analytics: analytics,
          attribution: attribution,
          adEvents: adEvents,
        ),
        'setGdprConsent',
      ),
    );
  }

  @override
  void setGdprConsentNotRequired() {
    _gdprConsentState = AttriaxGdprConsentState.notRequired;
    _isWaitingForGdprConsent = false;
    unawaited(
      _fireAndForget(
        () => _platform.setGdprConsentNotRequired(),
        'setGdprConsentNotRequired',
      ),
    );
  }

  @override
  void resetGdprConsent() {
    _gdprConsentState = AttriaxGdprConsentState.unknown;
    _gdprConsentValues = null;
    unawaited(
      _fireAndForget(() => _platform.resetGdprConsent(), 'resetGdprConsent'),
    );
  }

  @override
  Future<void> requestGdprDataErasure() async {
    await _platform.requestGdprDataErasure();
    _gdprConsentState = AttriaxGdprConsentState.unknown;
    _gdprConsentValues = null;
  }

  @override
  Future<bool> needsGdprConsent({bool localOnly = false}) =>
      _readOr(() => _platform.needsGdprConsent(localOnly: localOnly), false);

  @override
  bool? get ccpaDoNotSell => _ccpaDoNotSell;

  @override
  String? get ccpaUsPrivacy => _ccpaUsPrivacy;

  @override
  void setCcpaDoNotSell(bool? doNotSell) {
    _ccpaDoNotSell = doNotSell;
    unawaited(
      _fireAndForget(
        () => _platform.setCcpaConsent(doNotSell: doNotSell),
        'setCcpaConsent',
      ),
    );
  }

  @override
  void setCcpaUsPrivacy(String? usPrivacy) {
    _ccpaUsPrivacy = usPrivacy;
    unawaited(
      _fireAndForget(
        () => _platform.setCcpaConsent(usPrivacy: usPrivacy),
        'setCcpaConsent',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Deep links
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    try {
      return await _platform.recordDeepLink(
        uri: uri,
        metadata: metadata,
        source: source,
      );
    } on Object {
      // Bindings that only accept raw links resolve asynchronously through the
      // deep-link event stream; forward the URI and surface the resolution there.
      await _fireAndForget(
        () => _platform.handleIncomingLink(uri.toString()),
        'handleIncomingLink',
      );
      return null;
    }
  }

  @override
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() async {
    if (!_initialDeepLinkResolved && !_initialLinkProbe.isCompleted) {
      try {
        await _initialLinkProbe.future.timeout(const Duration(seconds: 10));
      } on TimeoutException {
        // Fall through with whatever has been cached so far.
      }
    }
    return _initialDeepLink;
  }

  @override
  Future<AttriaxDeepLinkEvent> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) async {
    try {
      final resolved = await _platform.waitForDeepLinkResolution(rawEvent);
      if (resolved != null) {
        return resolved;
      }
    } on Object {
      // Fall back to the next resolved event on the stream.
    }
    return _deepLinkController.stream.first;
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
  }) => _platform.createDynamicLink(
    name: name,
    destinationUrl: destinationUrl,
    group: group,
    prefix: prefix,
    socialPreview: socialPreview,
    utms: utms,
    redirects: redirects,
    data: data,
  );

  // ---------------------------------------------------------------------------
  // Revenue
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) => _platform.validateReceipt(
    receipt: receipt,
    test: test,
    provider: provider,
    environment: environment,
    productId: productId,
    transactionId: transactionId,
  );

  // ---------------------------------------------------------------------------
  // SKAdNetwork
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    final result = await _platform.updateSkanConversionValue(
      fineValue: fineValue,
      coarseValue: coarseValue,
      lockWindow: lockWindow,
    );
    _skanState = await _readOr(() => _platform.getSkanState(), _skanState);
    return result;
  }

  // ---------------------------------------------------------------------------
  // App Tracking Transparency
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _readOr(
    () => _platform.requestTrackingAuthorization(timeout: timeout),
    AttriaxTrackingAuthorizationStatus.notSupported,
  );

  @override
  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _readOr(
        () => _platform.getTrackingAuthorizationStatus(),
        AttriaxTrackingAuthorizationStatus.notSupported,
      );

  // ---------------------------------------------------------------------------
  // Referrers (null when unavailable; honors initialized/enabled/safe/timeout)
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    () => _platform.getOriginalInstallReferrer(timeout: timeout),
    safe: safe,
    timeout: timeout,
  );

  @override
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    () => _platform.getReinstallReferrer(timeout: timeout),
    safe: safe,
    timeout: timeout,
  );

  @override
  Future<String?> getRawInstallReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    () => _platform.getRawInstallReferrer(timeout: timeout),
    safe: safe,
    timeout: timeout,
  );

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    () => _platform.getSessionReferrer(timeout: timeout),
    safe: safe,
    timeout: timeout,
  );

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
    bool safe = false,
  }) => _readReferrer(
    () => _platform.getLatestDeepLinkReferrer(timeout: timeout),
    safe: safe,
    timeout: timeout,
  );

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Mirrors the pure-Dart runtime's referrer contract: `null` before init or
  /// while disabled; applies [timeout]; swallows errors to `null` only when
  /// [safe], otherwise rethrows.
  Future<T?> _readReferrer<T>(
    Future<T?> Function() reader, {
    required bool safe,
    Duration? timeout,
  }) async {
    if (!_initialized || !_sdkEnabled) {
      return null;
    }
    try {
      final future = timeout == null ? reader() : reader().timeout(timeout);
      return await future;
    } on Object {
      if (safe) {
        return null;
      }
      rethrow;
    }
  }

  /// Reads a value from the native engine, returning [fallback] when the binding
  /// has not implemented that call (or it otherwise fails).
  Future<T> _readOr<T>(Future<T> Function() read, T fallback) async {
    try {
      return await read();
    } on Object catch (e) {
      _logger.verbose('native read fell back to default: $e');
      return fallback;
    }
  }

  /// Invokes a fire-and-forget native command, logging (never throwing) when the
  /// binding has not implemented it.
  Future<void> _fireAndForget(
    Future<void> Function() command,
    String label,
  ) async {
    try {
      await command();
    } on Object catch (e) {
      _logger.verbose('native command "$label" ignored: $e');
    }
  }

  String? _trimOrNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
