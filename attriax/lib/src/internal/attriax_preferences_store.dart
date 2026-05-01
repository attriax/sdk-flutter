import 'dart:convert';

import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttriaxStoredPreferences {
  const AttriaxStoredPreferences({
    required this.deviceId,
    required this.hasPersistedDeviceId,
    required this.isEnabled,
    required this.areEventsEnabled,
    required this.isFirstLaunch,
    this.deviceIdSource,
  });

  final String deviceId;
  final bool hasPersistedDeviceId;
  final bool isEnabled;
  final bool areEventsEnabled;
  final bool isFirstLaunch;
  final String? deviceIdSource;
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
  AttriaxPreferencesStore({SharedPreferences? prefsOverride})
    : _prefsOverride = prefsOverride;

  static const String deviceIdStorageKey = 'attriax.device_id';
  static const String deviceIdSourceStorageKey = 'attriax.device_id_source';
  static const String enabledStorageKey = 'attriax.enabled';
  static const String eventsEnabledStorageKey = 'attriax.events.enabled';
  static const String firstLaunchSeenStorageKey = 'attriax.first_launch_seen';
  static const String installReferrerDetailsStorageKey =
      'attriax.install_referrer.details';

  final SharedPreferences? _prefsOverride;
  SharedPreferences? _prefs;

  Future<AttriaxStoredPreferences> restore({
    required String Function() deviceIdFactory,
    bool? enabledOverride,
    bool? eventsEnabledOverride,
  }) async {
    final prefs = await preferences;
    final storedDeviceId = await _loadOrCreateDeviceId(
      prefs,
      deviceIdFactory: deviceIdFactory,
    );
    final deviceIdSource = _sanitizeString(
      prefs.getString(deviceIdSourceStorageKey),
    );

    final hasSeenFirstLaunch =
        prefs.getBool(firstLaunchSeenStorageKey) ?? false;
    final isFirstLaunch = !hasSeenFirstLaunch;
    if (!hasSeenFirstLaunch) {
      await prefs.setBool(firstLaunchSeenStorageKey, true);
    }

    final isEnabled =
        enabledOverride ?? prefs.getBool(enabledStorageKey) ?? true;
    final areEventsEnabled =
        eventsEnabledOverride ?? prefs.getBool(eventsEnabledStorageKey) ?? true;

    await prefs.setBool(enabledStorageKey, isEnabled);
    await prefs.setBool(eventsEnabledStorageKey, areEventsEnabled);

    return AttriaxStoredPreferences(
      deviceId: storedDeviceId.value,
      hasPersistedDeviceId: storedDeviceId.hasPersistedValue,
      isEnabled: isEnabled,
      areEventsEnabled: areEventsEnabled,
      isFirstLaunch: isFirstLaunch,
      deviceIdSource: deviceIdSource,
    );
  }

  Future<void> setSdkEnabled({required bool enabled}) async {
    final prefs = await preferences;
    await prefs.setBool(enabledStorageKey, enabled);
  }

  Future<void> setEventsEnabled({required bool enabled}) async {
    final prefs = await preferences;
    await prefs.setBool(eventsEnabledStorageKey, enabled);
  }

  Future<void> setDeviceId({required String deviceId}) async {
    final prefs = await preferences;
    await prefs.setString(deviceIdStorageKey, deviceId);
  }

  Future<void> setDeviceIdSource({required String? deviceIdSource}) async {
    final prefs = await preferences;
    final normalized = _sanitizeString(deviceIdSource);
    if (normalized == null) {
      await prefs.remove(deviceIdSourceStorageKey);
      return;
    }

    await prefs.setString(deviceIdSourceStorageKey, normalized);
  }

  Future<AttriaxInstallReferrerDetails?> readInstallReferrerDetails() async {
    final prefs = await preferences;
    final rawValue = prefs.getString(installReferrerDetailsStorageKey);
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
    final prefs = await preferences;
    if (details == null) {
      await prefs.remove(installReferrerDetailsStorageKey);
      return;
    }

    await prefs.setString(
      installReferrerDetailsStorageKey,
      jsonEncode(details.toJson()),
    );
  }

  Future<SharedPreferences> get preferences async {
    _prefs ??= _prefsOverride ?? await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<_StoredDeviceIdState> _loadOrCreateDeviceId(
    SharedPreferences prefs, {
    required String Function() deviceIdFactory,
  }) async {
    final existing = _sanitizeString(prefs.getString(deviceIdStorageKey));
    if (existing != null) {
      return _StoredDeviceIdState(value: existing, hasPersistedValue: true);
    }

    final generated = deviceIdFactory();
    await prefs.setString(deviceIdStorageKey, generated);
    return _StoredDeviceIdState(value: generated, hasPersistedValue: false);
  }

  String? _sanitizeString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value;
  }
}
