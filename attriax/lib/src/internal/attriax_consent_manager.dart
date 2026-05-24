import 'dart:async';

import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';

import '../attriax_consent.dart';
import 'attriax_context_manager.dart';
import 'attriax_gdpr_region.dart';
import 'attriax_generated_transport.dart';
import 'attriax_id_generator.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

typedef AttriaxConsentStateListener = void Function();

abstract interface class AttriaxConsentReadView {
  AttriaxGdprConsentState get gdprConsentState;
  AttriaxGdprConsentValues? get gdprConsentValues;
  bool get isWaitingForGdprConsent;
  bool get shouldDeferNetworkDispatch;
  bool get allowsAnalyticsTracking;
  bool get allowsAttributionTracking;
  bool get allowsAdEventsTracking;
  bool get canCaptureAnalytics;
  bool get canCaptureAttribution;
  bool get canCaptureAdEvents;
  bool get canCaptureUninstallTracking;
  AttriaxTrackingDecision trackingDecisionFor(AttriaxTrackingSignal signal);
}

enum AttriaxTrackingSignal {
  analytics,
  adEvents,
  attribution,
  session,
  deepLink,
  uninstallTracking,
}

enum AttriaxTrackingIdentityMode { identified, anonymous, withheld }

class AttriaxTrackingDecision {
  const AttriaxTrackingDecision({
    required this.capture,
    required this.identityMode,
    required this.deferNetwork,
  });

  final bool capture;
  final AttriaxTrackingIdentityMode identityMode;
  final bool deferNetwork;

  bool get attachDeviceIdentity =>
      identityMode == AttriaxTrackingIdentityMode.identified;

  bool get sendNetworkDirectly => capture && !deferNetwork;
}

class AttriaxConsentManager implements AttriaxConsentReadView {
  AttriaxConsentManager({
    required AttriaxConfig config,
    required AttriaxClock clock,
    required AttriaxContextManager contextManager,
    required AttriaxConsentPersistenceStore preferencesStore,
    required AttriaxLogger logger,
  }) : _config = config,
       _clock = clock,
       _contextManager = contextManager,
       _preferencesStore = preferencesStore,
       _logger = logger;

  final AttriaxConfig _config;
  final AttriaxClock _clock;
  final AttriaxContextManager _contextManager;
  final AttriaxConsentPersistenceStore _preferencesStore;
  final AttriaxLogger _logger;

  AttriaxGeneratedTransport? _transport;
  AttriaxConsentStateListener? onStateChanged;

  AttriaxGdprConsentState _state = AttriaxGdprConsentState.unknown;
  AttriaxGdprConsentValues? _values;
  String? _countryCode;
  String? _regionSource;
  DateTime? _checkedAt;
  bool _pendingSync = false;
  bool _didRestore = false;
  Future<bool>? _needsConsentFuture;
  Future<void>? _pendingSyncFuture;
  Future<void>? _autoDetectFuture;

  @override
  AttriaxGdprConsentState get gdprConsentState => _state;

  @override
  AttriaxGdprConsentValues? get gdprConsentValues => _values;

  @override
  bool get isWaitingForGdprConsent =>
      _state == AttriaxGdprConsentState.pending ||
      _state == AttriaxGdprConsentState.unknown;

  @override
  bool get shouldDeferNetworkDispatch =>
      _config.gdprEnabled && isWaitingForGdprConsent;

  @override
  bool get allowsAnalyticsTracking =>
      _allowsCategory((values) => values.analytics);

  @override
  bool get allowsAttributionTracking =>
      _allowsCategory((values) => values.attribution);

  @override
  bool get allowsAdEventsTracking =>
      _allowsCategory((values) => values.adEvents);

  @override
  bool get canCaptureAnalytics => _canCaptureAnonymousCapableCategory();

  @override
  bool get canCaptureAttribution => _canCaptureCategory(
    (values) => values.attribution,
    allowWhileWaiting: false,
  );

  @override
  bool get canCaptureAdEvents => _canCaptureAnonymousCapableCategory();

  @override
  bool get canCaptureUninstallTracking => _canCaptureCategory(
    (values) => values.attribution,
    allowWhileWaiting: true,
  );

  @override
  AttriaxTrackingDecision trackingDecisionFor(AttriaxTrackingSignal signal) {
    if (!_config.gdprEnabled) {
      return const AttriaxTrackingDecision(
        capture: true,
        identityMode: AttriaxTrackingIdentityMode.identified,
        deferNetwork: false,
      );
    }

    if (isWaitingForGdprConsent) {
      return AttriaxTrackingDecision(
        capture: _canCaptureWhileWaiting(signal),
        identityMode: AttriaxTrackingIdentityMode.anonymous,
        deferNetwork: true,
      );
    }

    if (_state == AttriaxGdprConsentState.notRequired) {
      return const AttriaxTrackingDecision(
        capture: true,
        identityMode: AttriaxTrackingIdentityMode.identified,
        deferNetwork: false,
      );
    }

    final values = _values;
    if (_state != AttriaxGdprConsentState.granted || values == null) {
      return const AttriaxTrackingDecision(
        capture: false,
        identityMode: AttriaxTrackingIdentityMode.withheld,
        deferNetwork: false,
      );
    }

    final granted = _isSignalGranted(signal, values);
    if (granted) {
      return const AttriaxTrackingDecision(
        capture: true,
        identityMode: AttriaxTrackingIdentityMode.identified,
        deferNetwork: false,
      );
    }

    if (_isAnonymousCapableSignal(signal)) {
      return const AttriaxTrackingDecision(
        capture: true,
        identityMode: AttriaxTrackingIdentityMode.anonymous,
        deferNetwork: false,
      );
    }

    return const AttriaxTrackingDecision(
      capture: false,
      identityMode: AttriaxTrackingIdentityMode.withheld,
      deferNetwork: false,
    );
  }

  // ignore: use_setters_to_change_properties
  void bindTransport(AttriaxGeneratedTransport? transport) {
    _transport = transport;
  }

  Future<void> init() async {
    await _restore();
    _ensureAutoDetectStarted();
  }

  Future<void> flushPendingSync({required String appToken}) async {
    await _restore();
    await _flushPendingSync(appToken: appToken);
  }

  Future<bool> needsConsent({
    required String appToken,
    bool localOnly = false,
  }) async {
    await _restore();
    _ensureAutoDetectStarted();

    final canUseCachedState =
        (_state == AttriaxGdprConsentState.granted ||
            _state == AttriaxGdprConsentState.notRequired) &&
        (localOnly || !_shouldRefreshRemoteDecision);
    if (canUseCachedState) {
      if (!localOnly) {
        unawaited(_flushPendingSync(appToken: appToken));
      }
      return isWaitingForGdprConsent;
    }

    final inFlight = _needsConsentFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final resolution = _resolveNeedsConsent(
      appToken: appToken,
      localOnly: localOnly,
    );
    _needsConsentFuture = resolution;
    return resolution.whenComplete(() {
      if (identical(_needsConsentFuture, resolution)) {
        _needsConsentFuture = null;
      }
    });
  }

  void setConsent({
    required String appToken,
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) {
    _applyState(
      state: AttriaxGdprConsentState.granted,
      values: AttriaxGdprConsentValues(
        analytics: analytics,
        attribution: attribution,
        adEvents: adEvents,
      ),
      checkedAt: _clock.now(),
      countryCode: _countryCode,
      regionSource: 'manual',
      pendingSync: true,
    );
    unawaited(_persistAndFlush(appToken));
  }

  void setNotRequired({required String appToken}) {
    _applyState(
      state: AttriaxGdprConsentState.notRequired,
      values: null,
      checkedAt: _clock.now(),
      countryCode: _countryCode,
      regionSource: 'manual',
      pendingSync: true,
    );
    unawaited(_persistAndFlush(appToken));
  }

  void reset({required String appToken}) {
    _applyState(
      state: AttriaxGdprConsentState.unknown,
      values: null,
      checkedAt: _clock.now(),
      countryCode: null,
      regionSource: null,
      pendingSync: true,
    );
    unawaited(_persistAndFlush(appToken));
  }

  void clearMemory() {
    _state = AttriaxGdprConsentState.unknown;
    _values = null;
    _countryCode = null;
    _regionSource = null;
    _checkedAt = null;
    _pendingSync = false;
    _didRestore = false;
    _autoDetectFuture = null;
  }

  bool _allowsCategory(
    bool Function(AttriaxGdprConsentValues values) selector,
  ) {
    if (!_config.gdprEnabled) {
      return true;
    }

    switch (_state) {
      case AttriaxGdprConsentState.notRequired:
        return true;
      case AttriaxGdprConsentState.granted:
        final values = _values;
        return values != null && selector(values);
      case AttriaxGdprConsentState.pending:
      case AttriaxGdprConsentState.unknown:
        return false;
    }
  }

  bool _canCaptureCategory(
    bool Function(AttriaxGdprConsentValues values) selector, {
    required bool allowWhileWaiting,
  }) {
    if (!_config.gdprEnabled) {
      return true;
    }

    switch (_state) {
      case AttriaxGdprConsentState.notRequired:
        return true;
      case AttriaxGdprConsentState.granted:
        final values = _values;
        return values != null && selector(values);
      case AttriaxGdprConsentState.pending:
      case AttriaxGdprConsentState.unknown:
        return allowWhileWaiting;
    }
  }

  bool _canCaptureAnonymousCapableCategory() {
    if (!_config.gdprEnabled) {
      return true;
    }

    return true;
  }

  bool _canCaptureWhileWaiting(AttriaxTrackingSignal signal) =>
      switch (signal) {
        AttriaxTrackingSignal.analytics ||
        AttriaxTrackingSignal.adEvents ||
        AttriaxTrackingSignal.session ||
        AttriaxTrackingSignal.deepLink => true,
        AttriaxTrackingSignal.attribution ||
        AttriaxTrackingSignal.uninstallTracking => false,
      };

  bool _isAnonymousCapableSignal(AttriaxTrackingSignal signal) =>
      switch (signal) {
        AttriaxTrackingSignal.analytics ||
        AttriaxTrackingSignal.adEvents ||
        AttriaxTrackingSignal.session ||
        AttriaxTrackingSignal.deepLink => true,
        AttriaxTrackingSignal.attribution ||
        AttriaxTrackingSignal.uninstallTracking => false,
      };

  bool _isSignalGranted(
    AttriaxTrackingSignal signal,
    AttriaxGdprConsentValues values,
  ) => switch (signal) {
    AttriaxTrackingSignal.analytics => values.analytics,
    AttriaxTrackingSignal.adEvents => values.adEvents,
    AttriaxTrackingSignal.attribution => values.attribution,
    AttriaxTrackingSignal.session => values.analytics || values.adEvents,
    AttriaxTrackingSignal.deepLink => values.attribution,
    AttriaxTrackingSignal.uninstallTracking => values.attribution,
  };

  bool get _shouldRefreshRemoteDecision =>
      _regionSource == 'local_only_timezone' ||
      _regionSource == 'local_only_timezone_unresolved' ||
      _regionSource == 'auto_timezone' ||
      _regionSource == 'local_timezone_fallback';

  Future<bool> _resolveNeedsConsent({
    required String appToken,
    required bool localOnly,
  }) async {
    if (_pendingSync && _state == AttriaxGdprConsentState.unknown) {
      await _flushPendingSync(appToken: appToken);
      if (_pendingSync && _state == AttriaxGdprConsentState.unknown) {
        return true;
      }
    }

    if (!localOnly) {
      final transport = _transport;
      if (transport != null) {
        try {
          final consentId = await _ensureConsentId();
          final status = await transport.checkGdprConsent(
            appToken: appToken,
            consentId: consentId,
          );
          await _applyRemoteStatus(status, pendingSync: false);
          return isWaitingForGdprConsent;
        } catch (error, stackTrace) {
          _logger.warning(
            'Failed to check GDPR consent with Attriax. Falling back to local timezone detection.',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    }

    final resolvedTimezone = await _contextManager.resolveTimezone();
    final localState = attriaxResolveGdprStateForTimezone(resolvedTimezone);
    if (localState != null) {
      _applyState(
        state: localState,
        values: null,
        checkedAt: _clock.now(),
        countryCode: null,
        regionSource: localOnly
            ? 'local_only_timezone'
            : 'local_timezone_fallback',
        pendingSync: false,
      );
      await _persistCurrentState();
      return isWaitingForGdprConsent;
    }

    _applyState(
      state: AttriaxGdprConsentState.unknown,
      values: null,
      checkedAt: _clock.now(),
      countryCode: null,
      regionSource: localOnly
          ? 'local_only_timezone_unresolved'
          : 'local_timezone_unresolved',
      pendingSync: false,
    );
    await _persistCurrentState();
    return true;
  }

  void _ensureAutoDetectStarted() {
    if (!_config.gdprEnabled || !_config.gdprAutoDetect) {
      return;
    }
    if (_state != AttriaxGdprConsentState.unknown || _pendingSync) {
      return;
    }

    final inFlight = _autoDetectFuture;
    if (inFlight != null) {
      return;
    }

    final detection = _autoDetectLocalRequirement();
    _autoDetectFuture = detection;
    unawaited(
      detection.whenComplete(() {
        if (identical(_autoDetectFuture, detection)) {
          _autoDetectFuture = null;
        }
      }),
    );
  }

  Future<void> _autoDetectLocalRequirement() async {
    final resolvedTimezone = await _contextManager.resolveTimezone();
    if (_state != AttriaxGdprConsentState.unknown || _pendingSync) {
      return;
    }

    final localState = attriaxResolveGdprStateForTimezone(resolvedTimezone);
    if (localState == null) {
      return;
    }

    _applyState(
      state: localState,
      values: null,
      checkedAt: _clock.now(),
      countryCode: null,
      regionSource: 'auto_timezone',
      pendingSync: false,
    );
    await _persistCurrentState();
  }

  Future<void> _restore() async {
    if (_didRestore) {
      return;
    }

    final stored = await _preferencesStore.readGdprConsentData();
    if (stored == null) {
      _didRestore = true;
      return;
    }

    _state = _stateFromStorage(stored.state);
    _values = stored.values == null
        ? null
        : AttriaxGdprConsentValues(
            analytics: stored.values!.analytics,
            attribution: stored.values!.attribution,
            adEvents: stored.values!.adEvents,
          );
    _countryCode = stored.countryCode;
    _regionSource = stored.regionSource;
    _checkedAt = stored.checkedAt;
    _pendingSync = stored.pendingSync;
    _didRestore = true;
  }

  Future<void> _persistAndFlush(String appToken) async {
    await _persistCurrentState();
    await _flushPendingSync(appToken: appToken);
  }

  Future<void> _persistCurrentState() {
    if (!_pendingSync && _state == AttriaxGdprConsentState.unknown) {
      return _preferencesStore.setGdprConsentData(data: null);
    }

    return _preferencesStore.setGdprConsentData(
      data: AttriaxStoredGdprConsentData(
        state: _stateToStorage(_state),
        values: _values == null
            ? null
            : AttriaxStoredGdprConsentValues(
                analytics: _values!.analytics,
                attribution: _values!.attribution,
                adEvents: _values!.adEvents,
              ),
        countryCode: _countryCode,
        regionSource: _regionSource,
        checkedAt: _checkedAt,
        pendingSync: _pendingSync,
      ),
    );
  }

  Future<void> _flushPendingSync({required String appToken}) async {
    if (!_pendingSync) {
      return;
    }

    final transport = _transport;
    if (transport == null) {
      return;
    }

    final inFlight = _pendingSyncFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final sync = _syncPendingState(appToken: appToken, transport: transport);
    _pendingSyncFuture = sync;
    return sync.whenComplete(() {
      if (identical(_pendingSyncFuture, sync)) {
        _pendingSyncFuture = null;
      }
    });
  }

  Future<void> _syncPendingState({
    required String appToken,
    required AttriaxGeneratedTransport transport,
  }) async {
    try {
      final consentId = await _ensureConsentId();
      final status = await transport.upsertGdprConsent(
        appToken: appToken,
        consentId: consentId,
        state: _sdkStateFromPublic(_state),
        values: _values == null
            ? null
            : sdk.SdkV1GdprConsentValuesDto(
                analytics: _values!.analytics,
                attribution: _values!.attribution,
                adEvents: _values!.adEvents,
              ),
        countryCode: _countryCode,
        regionSource: _regionSource,
        clientOccurredAt: _checkedAt,
      );
      await _applyRemoteStatus(status, pendingSync: false);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to sync GDPR consent state to Attriax. The SDK will retry later.',
        error: error,
        stackTrace: stackTrace,
      );
      _pendingSync = true;
      await _persistCurrentState();
    }
  }

  Future<void> _applyRemoteStatus(
    sdk.SdkGdprConsentStatusDto status, {
    required bool pendingSync,
  }) async {
    var mappedState = _publicStateFromSdk(status.state);
    final mappedValues = status.values == null
        ? null
        : AttriaxGdprConsentValues(
            analytics: status.values!.analytics,
            attribution: status.values!.attribution,
            adEvents: status.values!.adEvents,
          );
    if (mappedState == AttriaxGdprConsentState.granted &&
        mappedValues == null) {
      mappedState = AttriaxGdprConsentState.pending;
    }

    _applyState(
      state: mappedState,
      values: mappedValues,
      checkedAt: status.checkedAt,
      countryCode: _normalizeString(status.countryCode),
      regionSource: _normalizeString(status.regionSource),
      pendingSync: pendingSync,
    );
    await _persistCurrentState();
  }

  void _applyState({
    required AttriaxGdprConsentState state,
    required AttriaxGdprConsentValues? values,
    required DateTime checkedAt,
    required String? countryCode,
    required String? regionSource,
    required bool pendingSync,
  }) {
    final changed =
        state != _state ||
        values != _values ||
        _normalizeString(countryCode) != _countryCode ||
        _normalizeString(regionSource) != _regionSource ||
        checkedAt != _checkedAt ||
        pendingSync != _pendingSync;

    _state = state;
    _values = values;
    _countryCode = _normalizeString(countryCode)?.toUpperCase();
    _regionSource = _normalizeString(regionSource);
    _checkedAt = checkedAt;
    _pendingSync = pendingSync;
    _didRestore = true;

    if (changed) {
      onStateChanged?.call();
    }
  }

  String? _normalizeString(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<String> _ensureConsentId() => _preferencesStore.ensureGdprConsentId(
    consentIdFactory: attriaxGenerateId,
  );

  AttriaxGdprConsentState _stateFromStorage(String rawState) {
    switch (rawState) {
      case 'not_required':
        return AttriaxGdprConsentState.notRequired;
      case 'pending':
        return AttriaxGdprConsentState.pending;
      case 'granted':
        return AttriaxGdprConsentState.granted;
      default:
        return AttriaxGdprConsentState.unknown;
    }
  }

  String _stateToStorage(AttriaxGdprConsentState state) {
    switch (state) {
      case AttriaxGdprConsentState.unknown:
        return 'unknown';
      case AttriaxGdprConsentState.notRequired:
        return 'not_required';
      case AttriaxGdprConsentState.pending:
        return 'pending';
      case AttriaxGdprConsentState.granted:
        return 'granted';
    }
  }

  sdk.AppUserGdprConsentState _sdkStateFromPublic(
    AttriaxGdprConsentState state,
  ) {
    switch (state) {
      case AttriaxGdprConsentState.unknown:
        return sdk.AppUserGdprConsentState.unknown;
      case AttriaxGdprConsentState.notRequired:
        return sdk.AppUserGdprConsentState.notRequired;
      case AttriaxGdprConsentState.pending:
        return sdk.AppUserGdprConsentState.pending;
      case AttriaxGdprConsentState.granted:
        return sdk.AppUserGdprConsentState.granted;
    }
  }

  AttriaxGdprConsentState _publicStateFromSdk(
    sdk.AppUserGdprConsentState state,
  ) {
    switch (state) {
      case sdk.AppUserGdprConsentState.notRequired:
        return AttriaxGdprConsentState.notRequired;
      case sdk.AppUserGdprConsentState.pending:
        return AttriaxGdprConsentState.pending;
      case sdk.AppUserGdprConsentState.granted:
        return AttriaxGdprConsentState.granted;
      case sdk.AppUserGdprConsentState.unknown:
        return AttriaxGdprConsentState.unknown;
    }
  }
}
