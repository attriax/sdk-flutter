import 'attriax_preferences_store.dart';

abstract interface class AttriaxRuntimeSettingsWriteStore {
  Future<void> setEnabled({required bool enabled});

  Future<void> setEventsEnabled({required bool enabled});
}

abstract interface class AttriaxRuntimeSettingsStore
    implements AttriaxRuntimeSettingsWriteStore {
  Future<AttriaxStoredRuntimePreferences> restore({
    bool? enabledOverride,
    bool? eventsEnabledOverride,
  });
}

class AttriaxPreferencesRuntimeSettingsStore
    implements AttriaxRuntimeSettingsStore {
  AttriaxPreferencesRuntimeSettingsStore({
    required AttriaxPreferencesStore preferencesStore,
  }) : _preferencesStore = preferencesStore;

  final AttriaxPreferencesStore _preferencesStore;

  @override
  Future<AttriaxStoredRuntimePreferences> restore({
    bool? enabledOverride,
    bool? eventsEnabledOverride,
  }) => _preferencesStore.restoreRuntimePreferences(
    enabledOverride: enabledOverride,
    eventsEnabledOverride: eventsEnabledOverride,
  );

  @override
  Future<void> setEnabled({required bool enabled}) =>
      _preferencesStore.setSdkEnabled(enabled: enabled);

  @override
  Future<void> setEventsEnabled({required bool enabled}) =>
      _preferencesStore.setEventsEnabled(enabled: enabled);
}
