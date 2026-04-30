import 'dart:convert';

import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttriaxStoredPreferences {
  const AttriaxStoredPreferences({
    required this.deviceId,
    required this.isEnabled,
    required this.areEventsEnabled,
    required this.isFirstLaunch,
  });

  final String deviceId;
  final bool isEnabled;
  final bool areEventsEnabled;
  final bool isFirstLaunch;
}

class AttriaxPreferencesStore {
  AttriaxPreferencesStore({SharedPreferences? prefsOverride})
    : _prefsOverride = prefsOverride;

  static const String deviceIdStorageKey = 'attriax.device_id';
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
    final deviceId = await _loadOrCreateDeviceId(
      prefs,
      deviceIdFactory: deviceIdFactory,
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
      deviceId: deviceId,
      isEnabled: isEnabled,
      areEventsEnabled: areEventsEnabled,
      isFirstLaunch: isFirstLaunch,
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

  Future<String> _loadOrCreateDeviceId(
    SharedPreferences prefs, {
    required String Function() deviceIdFactory,
  }) async {
    final existing = prefs.getString(deviceIdStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = deviceIdFactory();
    await prefs.setString(deviceIdStorageKey, generated);
    return generated;
  }
}
