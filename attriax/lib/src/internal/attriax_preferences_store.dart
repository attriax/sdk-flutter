import 'dart:convert';

import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AttriaxPersistenceDegradedCallback =
    void Function({required String operation, required Object error});

class AttriaxStoredRuntimePreferences {
  const AttriaxStoredRuntimePreferences({
    required this.isEnabled,
    required this.areEventsEnabled,
  });

  final bool isEnabled;
  final bool areEventsEnabled;
}

class AttriaxStoredDeviceData {
  const AttriaxStoredDeviceData({
    required this.deviceId,
    required this.hasPersistedDeviceId,
    required this.isFirstLaunch,
    this.deviceIdSource,
  });

  final String deviceId;
  final bool hasPersistedDeviceId;
  final bool isFirstLaunch;
  final String? deviceIdSource;
}

class AttriaxStoredPlatformInstallReferrer {
  const AttriaxStoredPlatformInstallReferrer({
    required this.isLoaded,
    required this.value,
  });

  final bool isLoaded;
  final String? value;
}

class AttriaxStoredInstallReferrerDetails {
  const AttriaxStoredInstallReferrerDetails({
    required this.isLoaded,
    required this.value,
  });

  final bool isLoaded;
  final AttriaxInstallReferrerDetails? value;
}

class _StoredDeviceIdState {
  const _StoredDeviceIdState({
    required this.value,
    required this.hasPersistedValue,
  });

  final String value;
  final bool hasPersistedValue;
}

class AttriaxPreferencesStore {
  AttriaxPreferencesStore({
    SharedPreferences? prefsOverride,
    Future<SharedPreferences> Function()? preferencesLoader,
    AttriaxPersistenceDegradedCallback? onPersistenceDegraded,
  }) : _prefsOverride = prefsOverride,
       _preferencesLoader = preferencesLoader,
       _onPersistenceDegraded = onPersistenceDegraded;

  static const String deviceIdStorageKey = 'attriax.device_id';
  static const String deviceIdSourceStorageKey = 'attriax.device_id_source';
  static const String enabledStorageKey = 'attriax.enabled';
  static const String eventsEnabledStorageKey = 'attriax.events.enabled';
  static const String firstLaunchSeenStorageKey = 'attriax.first_launch_seen';
  static const String platformInstallReferrerStorageKey =
      'attriax.install_referrer.platform';
  static const String platformInstallReferrerLoadedStorageKey =
      'attriax.install_referrer.platform.loaded';
  static const String installReferrerDetailsStorageKey =
      'attriax.install_referrer.details';
  static const String installReferrerDetailsLoadedStorageKey =
      'attriax.install_referrer.details.loaded';
  static const String reinstallReferrerDetailsStorageKey =
      'attriax.referrer.reinstall.details';
  static const String reinstallReferrerDetailsLoadedStorageKey =
      'attriax.referrer.reinstall.details.loaded';
  static const String deferredAppOpenDeepLinkHandledStorageKey =
      'attriax.deep_link.deferred_app_open_handled';
  static const String sessionSnapshotStorageKey = 'attriax.session.current';
  static const String queueStorageKey = 'attriax.queue.v1';
  static const String queueDiagnosticsStorageKey =
      'attriax.queue.diagnostics.v1';
  static const String pendingCrashReportStorageKey = 'attriax.crash.pending';
  static const String skanStateStorageKey = 'attriax.skan.state.v1';

  final SharedPreferences? _prefsOverride;
  final Future<SharedPreferences> Function()? _preferencesLoader;
  final AttriaxPersistenceDegradedCallback? _onPersistenceDegraded;
  final Map<String, Object?> _memoryValues = <String, Object?>{};

  SharedPreferences? _prefs;
  bool _didFailToLoadPreferences = false;
  Object? _lastPersistenceError;
  String? _lastPersistenceFailureOperation;

  bool get isPersistenceDegraded => _didFailToLoadPreferences;
  Object? get lastPersistenceError => _lastPersistenceError;
  String? get lastPersistenceFailureOperation =>
      _lastPersistenceFailureOperation;

  Future<AttriaxStoredRuntimePreferences> restoreRuntimePreferences({
    bool? enabledOverride,
    bool? eventsEnabledOverride,
  }) async {
    final isEnabled =
        enabledOverride ?? await _readBool(enabledStorageKey) ?? true;
    final areEventsEnabled =
        eventsEnabledOverride ??
        await _readBool(eventsEnabledStorageKey) ??
        true;

    await setRuntimeFlags(enabled: isEnabled, eventsEnabled: areEventsEnabled);

    return AttriaxStoredRuntimePreferences(
      isEnabled: isEnabled,
      areEventsEnabled: areEventsEnabled,
    );
  }

  Future<AttriaxStoredDeviceData> restoreDeviceData({
    required String Function() deviceIdFactory,
  }) async {
    final storedDeviceId = await _loadOrCreateDeviceId(
      deviceIdFactory: deviceIdFactory,
    );
    final deviceIdSource = _sanitizeString(
      await _readString(deviceIdSourceStorageKey),
    );

    final hasSeenFirstLaunch =
        await _readBool(firstLaunchSeenStorageKey) ?? false;
    final isFirstLaunch = !hasSeenFirstLaunch;
    if (!hasSeenFirstLaunch) {
      await _writeBool(firstLaunchSeenStorageKey, true);
    }

    return AttriaxStoredDeviceData(
      deviceId: storedDeviceId.value,
      hasPersistedDeviceId: storedDeviceId.hasPersistedValue,
      isFirstLaunch: isFirstLaunch,
      deviceIdSource: deviceIdSource,
    );
  }

  Future<void> setSdkEnabled({required bool enabled}) async {
    await _writeBool(enabledStorageKey, enabled);
  }

  Future<void> setEventsEnabled({required bool enabled}) async {
    await _writeBool(eventsEnabledStorageKey, enabled);
  }

  Future<void> setDeviceId({required String deviceId}) async {
    await _writeString(deviceIdStorageKey, deviceId);
  }

  Future<void> setResolvedDeviceIdentity({
    required String deviceId,
    required String? deviceIdSource,
  }) async {
    await _writeString(deviceIdStorageKey, deviceId);
    final normalized = _sanitizeString(deviceIdSource);
    if (normalized == null) {
      await _remove(deviceIdSourceStorageKey);
      return;
    }

    await _writeString(deviceIdSourceStorageKey, normalized);
  }

  Future<void> setDeviceIdSource({required String? deviceIdSource}) async {
    final normalized = _sanitizeString(deviceIdSource);
    if (normalized == null) {
      await _remove(deviceIdSourceStorageKey);
      return;
    }

    await _writeString(deviceIdSourceStorageKey, normalized);
  }

  Future<void> setRuntimeFlags({
    required bool enabled,
    required bool eventsEnabled,
  }) async {
    await _writeBool(enabledStorageKey, enabled);
    await _writeBool(eventsEnabledStorageKey, eventsEnabled);
  }

  Future<AttriaxStoredPlatformInstallReferrer>
  readStoredPlatformInstallReferrer() async =>
      AttriaxStoredPlatformInstallReferrer(
        isLoaded:
            await _readBool(platformInstallReferrerLoadedStorageKey) ?? false,
        value: _sanitizeString(
          await _readString(platformInstallReferrerStorageKey),
        ),
      );

  Future<void> setStoredPlatformInstallReferrer({
    required bool isLoaded,
    required String? value,
  }) async {
    await _writeBool(platformInstallReferrerLoadedStorageKey, isLoaded);

    final normalized = _sanitizeString(value);
    if (normalized == null) {
      await _remove(platformInstallReferrerStorageKey);
      return;
    }

    await _writeString(platformInstallReferrerStorageKey, normalized);
  }

  Future<AttriaxInstallReferrerDetails?> readInstallReferrerDetails() async {
    final rawValue = await _readString(installReferrerDetailsStorageKey);
    return _readInstallReferrerDetailsFromRawValue(rawValue);
  }

  Future<AttriaxInstallReferrerDetails?> readReinstallReferrerDetails() async {
    final rawValue = await _readString(reinstallReferrerDetailsStorageKey);
    return _readInstallReferrerDetailsFromRawValue(rawValue);
  }

  AttriaxInstallReferrerDetails? _readInstallReferrerDetailsFromRawValue(
    String? rawValue,
  ) {
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return null;
      }

      return AttriaxInstallReferrerDetails.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value as Object?)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setInstallReferrerDetails({
    required AttriaxInstallReferrerDetails? details,
  }) async {
    await _writeInstallReferrerDetails(
      storageKey: installReferrerDetailsStorageKey,
      details: details,
    );
  }

  Future<void> setReinstallReferrerDetails({
    required AttriaxInstallReferrerDetails? details,
  }) async {
    await _writeInstallReferrerDetails(
      storageKey: reinstallReferrerDetailsStorageKey,
      details: details,
    );
  }

  Future<void> _writeInstallReferrerDetails({
    required String storageKey,
    required AttriaxInstallReferrerDetails? details,
  }) async {
    if (details == null) {
      await _remove(storageKey);
      return;
    }

    await _writeString(storageKey, jsonEncode(details.toJson()));
  }

  Future<AttriaxStoredInstallReferrerDetails>
  readStoredInstallReferrerDetails() async =>
      AttriaxStoredInstallReferrerDetails(
        isLoaded:
            await _readBool(installReferrerDetailsLoadedStorageKey) ?? false,
        value: await readInstallReferrerDetails(),
      );

  Future<void> setStoredInstallReferrerDetails({
    required bool isLoaded,
    required AttriaxInstallReferrerDetails? details,
  }) async {
    await _writeBool(installReferrerDetailsLoadedStorageKey, isLoaded);
    await setInstallReferrerDetails(details: details);
  }

  Future<AttriaxStoredInstallReferrerDetails>
  readStoredReinstallReferrerDetails() async =>
      AttriaxStoredInstallReferrerDetails(
        isLoaded:
            await _readBool(reinstallReferrerDetailsLoadedStorageKey) ?? false,
        value: await readReinstallReferrerDetails(),
      );

  Future<void> setStoredReinstallReferrerDetails({
    required bool isLoaded,
    required AttriaxInstallReferrerDetails? details,
  }) async {
    await _writeBool(reinstallReferrerDetailsLoadedStorageKey, isLoaded);
    await setReinstallReferrerDetails(details: details);
  }

  Future<bool> readDeferredAppOpenDeepLinkHandled() async =>
      await _readBool(deferredAppOpenDeepLinkHandledStorageKey) ?? false;

  Future<void> setDeferredAppOpenDeepLinkHandled({required bool value}) async {
    await _writeBool(deferredAppOpenDeepLinkHandledStorageKey, value);
  }

  Future<AttriaxSessionSnapshot?> readSessionSnapshot() async {
    final rawValue = await _readString(sessionSnapshotStorageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return null;
      }

      return AttriaxSessionSnapshot.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value as Object?)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setSessionSnapshot({
    required AttriaxSessionSnapshot? session,
  }) async {
    if (session == null) {
      await _remove(sessionSnapshotStorageKey);
      return;
    }

    await _writeString(sessionSnapshotStorageKey, jsonEncode(session.toJson()));
  }

  Future<AttriaxSkanState?> readSkanState() async {
    final rawValue = await _readString(skanStateStorageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return null;
      }

      return AttriaxSkanState.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value as Object?)),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setSkanState({required AttriaxSkanState? state}) async {
    if (state == null) {
      await _remove(skanStateStorageKey);
      return;
    }

    await _writeString(skanStateStorageKey, jsonEncode(state.toJson()));
  }

  Future<String?> readQueuePayload() => _readString(queueStorageKey);

  Future<void> writeQueuePayload(String? value) async {
    if (value == null || value.isEmpty) {
      await _remove(queueStorageKey);
      return;
    }

    await _writeString(queueStorageKey, value);
  }

  Future<String?> readQueueDiagnosticsPayload() =>
      _readString(queueDiagnosticsStorageKey);

  Future<void> writeQueueDiagnosticsPayload(String? value) async {
    if (value == null || value.isEmpty) {
      await _remove(queueDiagnosticsStorageKey);
      return;
    }

    await _writeString(queueDiagnosticsStorageKey, value);
  }

  Future<String?> readPendingCrashReportPayload() =>
      _readString(pendingCrashReportStorageKey);

  Future<void> writePendingCrashReportPayload(String? value) async {
    if (value == null || value.isEmpty) {
      await _remove(pendingCrashReportStorageKey);
      return;
    }

    await _writeString(pendingCrashReportStorageKey, value);
  }

  Future<SharedPreferences?> sharedPreferencesOrNull() => _preferencesOrNull();

  Future<void> clearAll() async {
    const keys = <String>[
      deviceIdStorageKey,
      deviceIdSourceStorageKey,
      enabledStorageKey,
      eventsEnabledStorageKey,
      firstLaunchSeenStorageKey,
      platformInstallReferrerStorageKey,
      platformInstallReferrerLoadedStorageKey,
      installReferrerDetailsStorageKey,
      installReferrerDetailsLoadedStorageKey,
      reinstallReferrerDetailsStorageKey,
      reinstallReferrerDetailsLoadedStorageKey,
      sessionSnapshotStorageKey,
      queueStorageKey,
      queueDiagnosticsStorageKey,
      pendingCrashReportStorageKey,
    ];

    for (final key in keys) {
      await _remove(key);
    }
  }

  Future<_StoredDeviceIdState> _loadOrCreateDeviceId({
    required String Function() deviceIdFactory,
  }) async {
    final existing = _sanitizeString(await _readString(deviceIdStorageKey));
    if (existing != null) {
      return _StoredDeviceIdState(value: existing, hasPersistedValue: true);
    }

    final generated = deviceIdFactory();
    await _writeString(deviceIdStorageKey, generated);
    return _StoredDeviceIdState(value: generated, hasPersistedValue: false);
  }

  Future<bool?> _readBool(String key) async {
    final prefs = await _preferencesOrNull();
    if (prefs != null) {
      return prefs.getBool(key) ?? _memoryValues[key] as bool?;
    }

    return _memoryValues[key] as bool?;
  }

  Future<String?> _readString(String key) async {
    final prefs = await _preferencesOrNull();
    if (prefs != null) {
      return prefs.getString(key) ?? _memoryValues[key] as String?;
    }

    return _memoryValues[key] as String?;
  }

  Future<void> _writeBool(String key, bool value) async {
    _memoryValues[key] = value;
    final prefs = await _preferencesOrNull();
    if (prefs == null) {
      return;
    }

    try {
      await prefs.setBool(key, value);
    } catch (error) {
      _markPersistenceFailure(operation: 'setBool($key)', error: error);
    }
  }

  Future<void> _writeString(String key, String value) async {
    _memoryValues[key] = value;
    final prefs = await _preferencesOrNull();
    if (prefs == null) {
      return;
    }

    try {
      await prefs.setString(key, value);
    } catch (error) {
      _markPersistenceFailure(operation: 'setString($key)', error: error);
    }
  }

  Future<void> _remove(String key) async {
    _memoryValues.remove(key);
    final prefs = await _preferencesOrNull();
    if (prefs == null) {
      return;
    }

    try {
      await prefs.remove(key);
    } catch (error) {
      _markPersistenceFailure(operation: 'remove($key)', error: error);
    }
  }

  Future<SharedPreferences?> _preferencesOrNull() async {
    if (_prefs != null) {
      return _prefs;
    }
    if (_didFailToLoadPreferences) {
      return null;
    }
    if (_prefsOverride != null) {
      _prefs = _prefsOverride;
      return _prefs;
    }

    try {
      _prefs = await (_preferencesLoader ?? SharedPreferences.getInstance)();
      return _prefs;
    } catch (error) {
      _markPersistenceFailure(operation: 'loadPreferences', error: error);
      return null;
    }
  }

  void _markPersistenceFailure({
    required String operation,
    required Object error,
  }) {
    final wasDegraded = _didFailToLoadPreferences;
    _didFailToLoadPreferences = true;
    _lastPersistenceError = error;
    _lastPersistenceFailureOperation = operation;
    if (!wasDegraded) {
      _onPersistenceDegraded?.call(operation: operation, error: error);
    }
  }

  String? _sanitizeString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value;
  }
}
