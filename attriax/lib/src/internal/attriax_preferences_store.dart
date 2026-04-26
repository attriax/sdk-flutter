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
