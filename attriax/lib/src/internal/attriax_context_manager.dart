import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_context_services.dart';
import 'attriax_id_generator.dart';
import 'attriax_logger.dart';
import 'attriax_preferences_store.dart';

abstract interface class AttriaxTrackingContext {
  String get requiredDeviceId;
  AttriaxContextSnapshot get requiredSnapshot;

  String requireDeviceIdSource();
}

/// Owns the in-memory Attriax runtime context and device identity state.
class AttriaxContextManager implements AttriaxTrackingContext {
  AttriaxContextManager({
    required AttriaxContextRuntimeServices contextCollector,
    required AttriaxContextIdentityStore preferencesStore,
    required AttriaxLogger logger,
  }) : _contextCollector = contextCollector,
       _preferencesStore = preferencesStore,
       _logger = logger;

  final AttriaxContextRuntimeServices _contextCollector;
  final AttriaxContextIdentityStore _preferencesStore;
  final AttriaxLogger _logger;

  String? _deviceId;
  String? _deviceIdSource;
  bool _isFirstLaunch = false;
  AttriaxContextSnapshot? _snapshot;

  String? get deviceId => _deviceId;
  String? get deviceIdSource => _deviceIdSource;
  bool get isFirstLaunch => _isFirstLaunch;
  AttriaxSdkSnapshot? get sdkSnapshot => _snapshot?.sdk;
  AttriaxContextSnapshot? get snapshot => _snapshot;

  @override
  String get requiredDeviceId {
    final value = _deviceId;
    if (value == null || value.isEmpty) {
      throw StateError('Attriax context not initialized. Call init() first.');
    }

    return value;
  }

  @override
  AttriaxContextSnapshot get requiredSnapshot {
    final value = _snapshot;
    if (value == null) {
      throw StateError('Attriax context not initialized. Call init() first.');
    }

    return value;
  }

  Future<void> ensureDeviceIdentity() async {
    if (_deviceId != null && _deviceId!.isNotEmpty && _deviceIdSource != null) {
      return;
    }

    final storedDeviceIdentity = await _preferencesStore.ensureDeviceIdentity(
      deviceIdFactory: attriaxGenerateId,
    );

    _deviceId ??= storedDeviceIdentity.deviceId;
    _deviceIdSource ??= storedDeviceIdentity.deviceIdSource;
    await _ensureResolvedDeviceIdentity(
      hasPersistedDeviceId: storedDeviceIdentity.hasPersistedDeviceId,
    );
  }

  Future<void> init({bool allowDeviceIdentity = true}) async {
    _isFirstLaunch = await _preferencesStore.restoreFirstLaunchState();

    if (!allowDeviceIdentity) {
      final timezone = await resolveTimezone();
      _snapshot = _contextCollector.buildAnonymousStartupSnapshot(
        isFirstLaunch: _isFirstLaunch,
        timezone: timezone,
      );
      return;
    }

    await ensureIdentifiedContext(waitForTrackingAuthorization: false);
  }

  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) => _contextCollector.requestTrackingAuthorization(timeout: timeout);

  Future<AttriaxTrackingAuthorizationStatus> getTrackingAuthorizationStatus() =>
      _contextCollector.getTrackingAuthorizationStatus();

  /// Resolves the App Tracking Transparency status settled during startup, used
  /// to stamp `attStatus` on the app-open request (Epic 8.5).
  Future<AttriaxTrackingAuthorizationStatus>
  waitForTrackingAuthorizationIfNeeded() =>
      _contextCollector.waitForTrackingAuthorizationIfNeeded();

  Future<String?> resolveTimezone() =>
      _contextCollector.resolveDeviceTimezone();

  Future<void> setAutomaticCrashReportingEnabled({required bool enabled}) =>
      _contextCollector.setAutomaticCrashReportingEnabled(enabled: enabled);

  Future<AttriaxContextSnapshot> ensureIdentifiedContext({
    bool waitForTrackingAuthorization = false,
  }) async {
    await ensureDeviceIdentity();
    return refreshSnapshot(
      waitForTrackingAuthorization: waitForTrackingAuthorization,
    );
  }

  Future<AttriaxContextSnapshot> refreshSnapshot({
    bool waitForTrackingAuthorization = false,
  }) async {
    _snapshot = await _contextCollector.collectContextSnapshot(
      deviceId: requiredDeviceId,
      isFirstLaunch: _isFirstLaunch,
      waitForTrackingAuthorization: waitForTrackingAuthorization,
    );

    return requiredSnapshot;
  }

  Future<AttriaxContextSnapshot> ensureResolvedForAppOpen({
    bool waitForTrackingAuthorization = true,
  }) => ensureIdentifiedContext(
    waitForTrackingAuthorization: waitForTrackingAuthorization,
  );

  void reset() {
    _deviceId = null;
    _deviceIdSource = null;
    _isFirstLaunch = false;
    _snapshot = null;
  }

  @override
  String requireDeviceIdSource() {
    final source = _deviceIdSource?.trim();
    if (source == null || source.isEmpty) {
      return attriaxPersistentStorageDeviceIdSource;
    }

    return source;
  }

  Future<void> _ensureResolvedDeviceIdentity({
    required bool hasPersistedDeviceId,
  }) async {
    late final AttriaxResolvedDeviceId resolvedDeviceId;
    if (_deviceIdSource != null) {
      resolvedDeviceId = AttriaxResolvedDeviceId(
        value: requiredDeviceId,
        source: _deviceIdSource!,
        isFallback: _deviceIdSource == attriaxPersistentStorageDeviceIdSource,
      );
    } else if (hasPersistedDeviceId) {
      resolvedDeviceId = AttriaxResolvedDeviceId(
        value: requiredDeviceId,
        source: attriaxPersistentStorageDeviceIdSource,
        isFallback: true,
      );
    } else {
      resolvedDeviceId = await _contextCollector.resolvePreferredDeviceId(
        fallbackDeviceId: requiredDeviceId,
      );
    }

    if (_deviceId != resolvedDeviceId.value) {
      _deviceId = resolvedDeviceId.value;
    }
    _deviceIdSource = resolvedDeviceId.source;
    await _preferencesStore.setResolvedDeviceIdentity(
      deviceId: requiredDeviceId,
      deviceIdSource: _deviceIdSource,
    );
    _logger.verbose(
      'Using device ID (${resolvedDeviceId.source}): $requiredDeviceId',
    );
  }
}
