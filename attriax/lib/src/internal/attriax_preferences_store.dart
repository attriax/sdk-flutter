import 'dart:convert';

// ignore_for_file: annotate_overrides

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AttriaxPersistenceDegradedCallback =
    void Function({required String operation, required Object error});

enum AttriaxRuntimePersistenceMode { consentOnly, fullRuntime }

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

class AttriaxStoredDeviceIdentity {
  const AttriaxStoredDeviceIdentity({
    required this.deviceId,
    required this.hasPersistedDeviceId,
    this.deviceIdSource,
  });

  final String deviceId;
  final bool hasPersistedDeviceId;
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

class AttriaxStoredGdprConsentValues {
  const AttriaxStoredGdprConsentValues({
    required this.analytics,
    required this.attribution,
    required this.adEvents,
  });

  final bool analytics;
  final bool attribution;
  final bool adEvents;

  Map<String, Object?> toJson() => <String, Object?>{
    'analytics': analytics,
    'attribution': attribution,
    'adEvents': adEvents,
  };
}

class AttriaxStoredGdprConsentData {
  const AttriaxStoredGdprConsentData({
    required this.state,
    required this.pendingSync,
    this.values,
    this.countryCode,
    this.regionSource,
    this.checkedAt,
  });

  final String state;
  final bool pendingSync;
  final AttriaxStoredGdprConsentValues? values;
  final String? countryCode;
  final String? regionSource;
  final DateTime? checkedAt;
}

abstract interface class AttriaxContextIdentityStore {
  Future<AttriaxStoredDeviceData> restoreDeviceData({
    required String Function() deviceIdFactory,
  });

  Future<AttriaxStoredDeviceIdentity> ensureDeviceIdentity({
    required String Function() deviceIdFactory,
  });

  Future<void> setResolvedDeviceIdentity({
    required String deviceId,
    required String? deviceIdSource,
  });
}

abstract interface class AttriaxConsentPersistenceStore {
  Future<String> ensureGdprConsentId({
    required String Function() consentIdFactory,
  });

  Future<AttriaxStoredGdprConsentData?> readGdprConsentData();

  Future<void> setGdprConsentData({
    required AttriaxStoredGdprConsentData? data,
  });
}

abstract interface class AttriaxPlatformInstallReferrerStore {
  Future<AttriaxStoredPlatformInstallReferrer>
  readStoredPlatformInstallReferrer();

  Future<void> setStoredPlatformInstallReferrer({
    required bool isLoaded,
    required String? value,
  });

  Future<void> clearStoredPlatformInstallReferrer();
}

abstract interface class AttriaxInstallReferrerDetailsStore {
  Future<AttriaxStoredInstallReferrerDetails>
  readStoredInstallReferrerDetails();

  Future<void> setStoredInstallReferrerDetails({
    required AttriaxInstallReferrerDetails? details,
    required bool isLoaded,
  });

  Future<void> clearStoredInstallReferrerDetails();

  Future<AttriaxStoredInstallReferrerDetails>
  readStoredReinstallReferrerDetails();

  Future<void> setStoredReinstallReferrerDetails({
    required AttriaxInstallReferrerDetails? details,
    required bool isLoaded,
  });

  Future<void> clearStoredReinstallReferrerDetails();
}

abstract interface class AttriaxDeepLinkStateStore {
  Future<bool> readDeferredAppOpenDeepLinkHandled();

  Future<void> setDeferredAppOpenDeepLinkHandled({required bool value});
}

abstract interface class AttriaxSessionStore {
  Future<AttriaxSessionSnapshot?> readSessionSnapshot();

  Future<void> setSessionSnapshot({required AttriaxSessionSnapshot? session});
}

abstract interface class AttriaxSkanStore {
  Future<AttriaxSkanState?> readSkanState();

  Future<void> setSkanState({required AttriaxSkanState? state});
}

abstract interface class AttriaxQueueStore {
  Future<String?> readQueuePayload();

  Future<void> writeQueuePayload(String? value);

  Future<String?> readQueueDiagnosticsPayload();

  Future<void> writeQueueDiagnosticsPayload(String? value);
}

abstract interface class AttriaxCrashStore {
  Future<String?> readPendingCrashReportPayload();

  Future<void> writePendingCrashReportPayload(String? value);
}

class _StoredDeviceIdState {
  const _StoredDeviceIdState({
    required this.value,
    required this.hasPersistedValue,
  });

  final String value;
  final bool hasPersistedValue;
}

class AttriaxPreferencesStore
    implements
        AttriaxContextIdentityStore,
        AttriaxConsentPersistenceStore,
        AttriaxPlatformInstallReferrerStore,
        AttriaxInstallReferrerDetailsStore,
        AttriaxDeepLinkStateStore,
        AttriaxSessionStore,
        AttriaxSkanStore,
        AttriaxQueueStore,
        AttriaxCrashStore {
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
  static const String gdprConsentStorageKey = 'attriax.gdpr.consent.v1';
  static const String gdprConsentIdStorageKey = 'attriax.gdpr.consent_id.v1';

  static const Set<String> _runtimeScopedStorageKeys = <String>{
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
    deferredAppOpenDeepLinkHandledStorageKey,
    sessionSnapshotStorageKey,
    queueStorageKey,
    queueDiagnosticsStorageKey,
    pendingCrashReportStorageKey,
    skanStateStorageKey,
  };

  static const Set<String> _consentScopedStorageKeys = <String>{
    gdprConsentStorageKey,
    gdprConsentIdStorageKey,
  };

  static const Set<String> _allStorageKeys = <String>{
    ..._runtimeScopedStorageKeys,
    ..._consentScopedStorageKeys,
  };

  final SharedPreferences? _prefsOverride;
  final Future<SharedPreferences> Function()? _preferencesLoader;
  final AttriaxPersistenceDegradedCallback? _onPersistenceDegraded;
  final Map<String, Object?> _memoryValues = <String, Object?>{};

  SharedPreferences? _prefs;
  bool _didFailToLoadPreferences = false;
  Object? _lastPersistenceError;
  String? _lastPersistenceFailureOperation;
  AttriaxRuntimePersistenceMode _runtimePersistenceMode =
      AttriaxRuntimePersistenceMode.fullRuntime;

  bool get isPersistenceDegraded => _didFailToLoadPreferences;
  Object? get lastPersistenceError => _lastPersistenceError;
  String? get lastPersistenceFailureOperation =>
      _lastPersistenceFailureOperation;

  Future<void> setRuntimePersistenceMode({
    required AttriaxRuntimePersistenceMode mode,
  }) async {
    if (_runtimePersistenceMode == mode) {
      return;
    }

    _runtimePersistenceMode = mode;
    if (mode == AttriaxRuntimePersistenceMode.fullRuntime) {
      await _syncMemoryValuesToPersistentStorage();
      return;
    }

    await _clearRuntimeScopedPersistentStorage();
  }

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
    final storedDeviceIdentity = await ensureDeviceIdentity(
      deviceIdFactory: deviceIdFactory,
    );

    final hasSeenFirstLaunch =
        await _readBool(firstLaunchSeenStorageKey) ?? false;
    final isFirstLaunch = !hasSeenFirstLaunch;
    if (!hasSeenFirstLaunch) {
      await _writeBool(firstLaunchSeenStorageKey, true);
    }

    return AttriaxStoredDeviceData(
      deviceId: storedDeviceIdentity.deviceId,
      hasPersistedDeviceId: storedDeviceIdentity.hasPersistedDeviceId,
      isFirstLaunch: isFirstLaunch,
      deviceIdSource: storedDeviceIdentity.deviceIdSource,
    );
  }

  Future<AttriaxStoredDeviceIdentity> ensureDeviceIdentity({
    required String Function() deviceIdFactory,
  }) async {
    final storedDeviceId = await _loadOrCreateDeviceId(
      deviceIdFactory: deviceIdFactory,
    );
    final deviceIdSource = _sanitizeString(
      await _readString(deviceIdSourceStorageKey),
    );

    return AttriaxStoredDeviceIdentity(
      deviceId: storedDeviceId.value,
      hasPersistedDeviceId: storedDeviceId.hasPersistedValue,
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

  Future<String> ensureGdprConsentId({
    required String Function() consentIdFactory,
  }) async {
    final existing = _sanitizeString(
      await _readString(gdprConsentIdStorageKey),
    );
    if (existing != null) {
      return existing;
    }

    final generated = consentIdFactory();
    await _writeString(gdprConsentIdStorageKey, generated);
    return generated;
  }

  Future<String?> readStoredGdprConsentId() async =>
      _sanitizeString(await _readString(gdprConsentIdStorageKey));

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

  Future<void> clearStoredPlatformInstallReferrer() async {
    await _remove(platformInstallReferrerLoadedStorageKey);
    await _remove(platformInstallReferrerStorageKey);
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

  Future<void> clearStoredInstallReferrerDetails() async {
    await _remove(installReferrerDetailsLoadedStorageKey);
    await _remove(installReferrerDetailsStorageKey);
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

  Future<void> clearStoredReinstallReferrerDetails() async {
    await _remove(reinstallReferrerDetailsLoadedStorageKey);
    await _remove(reinstallReferrerDetailsStorageKey);
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

  Future<AttriaxStoredGdprConsentData?> readGdprConsentData() async {
    final rawValue = await _readString(gdprConsentStorageKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return null;
      }

      final data = decoded.map(
        (key, value) => MapEntry(key.toString(), value as Object?),
      );
      final valuesRaw = data['values'];
      AttriaxStoredGdprConsentValues? values;
      if (valuesRaw is Map) {
        final mappedValues = valuesRaw.map(
          (key, value) => MapEntry(key.toString(), value as Object?),
        );
        final analytics = mappedValues['analytics'];
        final attribution = mappedValues['attribution'];
        final adEvents = mappedValues['adEvents'];
        if (analytics is bool && attribution is bool && adEvents is bool) {
          values = AttriaxStoredGdprConsentValues(
            analytics: analytics,
            attribution: attribution,
            adEvents: adEvents,
          );
        }
      }

      final checkedAtRaw = data['checkedAt'];
      final checkedAt = checkedAtRaw is String
          ? DateTime.tryParse(checkedAtRaw)
          : null;
      final pendingSync = data['pendingSync'];
      final state = data['state'];
      if (pendingSync is! bool || state is! String || state.trim().isEmpty) {
        return null;
      }

      return AttriaxStoredGdprConsentData(
        state: state,
        pendingSync: pendingSync,
        values: values,
        countryCode: _sanitizeString(data['countryCode'] as String?),
        regionSource: _sanitizeString(data['regionSource'] as String?),
        checkedAt: checkedAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> setGdprConsentData({
    required AttriaxStoredGdprConsentData? data,
  }) async {
    if (data == null) {
      await _remove(gdprConsentStorageKey);
      return;
    }

    await _writeString(
      gdprConsentStorageKey,
      jsonEncode(<String, Object?>{
        'state': data.state,
        'pendingSync': data.pendingSync,
        if (data.values != null) 'values': data.values!.toJson(),
        if (data.countryCode != null) 'countryCode': data.countryCode,
        if (data.regionSource != null) 'regionSource': data.regionSource,
        if (data.checkedAt != null)
          'checkedAt': data.checkedAt!.toUtc().toIso8601String(),
      }),
    );
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
    for (final key in _allStorageKeys) {
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
    if (_memoryValues.containsKey(key)) {
      return _memoryValues[key] as bool?;
    }

    if (!_canUsePersistentStorageForKey(key)) {
      return null;
    }

    final prefs = await _preferencesOrNull();
    if (prefs != null) {
      return prefs.getBool(key);
    }

    return null;
  }

  Future<String?> _readString(String key) async {
    if (_memoryValues.containsKey(key)) {
      return _memoryValues[key] as String?;
    }

    if (!_canUsePersistentStorageForKey(key)) {
      return null;
    }

    final prefs = await _preferencesOrNull();
    if (prefs != null) {
      return prefs.getString(key);
    }

    return null;
  }

  Future<void> _writeBool(String key, bool value) async {
    _memoryValues[key] = value;
    if (!_canUsePersistentStorageForKey(key)) {
      await _removePersistedValue(key);
      return;
    }

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
    if (!_canUsePersistentStorageForKey(key)) {
      await _removePersistedValue(key);
      return;
    }

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
    await _removePersistedValue(key);
  }

  Future<void> _removePersistedValue(String key) async {
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

  bool _canUsePersistentStorageForKey(String key) {
    if (_consentScopedStorageKeys.contains(key)) {
      return true;
    }

    return _runtimePersistenceMode == AttriaxRuntimePersistenceMode.fullRuntime;
  }

  Future<void> _clearRuntimeScopedPersistentStorage() async {
    for (final key in _runtimeScopedStorageKeys) {
      await _removePersistedValue(key);
    }
  }

  Future<void> _syncMemoryValuesToPersistentStorage() async {
    final prefs = await _preferencesOrNull();
    if (prefs == null) {
      return;
    }

    final entries = _memoryValues.entries.toList(growable: false);
    for (final entry in entries) {
      if (!_canUsePersistentStorageForKey(entry.key)) {
        continue;
      }

      try {
        final value = entry.value;
        if (value is bool) {
          await prefs.setBool(entry.key, value);
          continue;
        }
        if (value is String) {
          await prefs.setString(entry.key, value);
          continue;
        }
      } catch (error) {
        _markPersistenceFailure(
          operation: 'syncMemory(${entry.key})',
          error: error,
        );
      }
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
