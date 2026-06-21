import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_runtime_settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxRuntimeSettingsStore', () {
    late SharedPreferences prefs;
    late AttriaxPreferencesStore preferencesStore;
    late AttriaxRuntimeSettingsStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      preferencesStore = AttriaxPreferencesStore(prefsOverride: prefs);
      store = AttriaxPreferencesRuntimeSettingsStore(
        preferencesStore: preferencesStore,
      );
    });

    test(
      'restores persisted runtime settings without touching device state',
      () async {
        final restoredSettings = await store.restore(
          enabledOverride: false,
          eventsEnabledOverride: true,
        );

        expect(restoredSettings.isEnabled, isFalse);
        expect(restoredSettings.areEventsEnabled, isTrue);
        expect(
          prefs.getBool(AttriaxPreferencesStore.enabledStorageKey),
          isFalse,
        );
        expect(
          prefs.getBool(AttriaxPreferencesStore.eventsEnabledStorageKey),
          isTrue,
        );
        expect(
          prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
          isNull,
        );
      },
    );

    test(
      'falls back to in-memory values when preferences loading fails',
      () async {
        final degradedOperations = <String>[];
        final failingPreferencesStore = AttriaxPreferencesStore(
          preferencesLoader: () async => throw StateError('prefs unavailable'),
          onPersistenceDegraded: ({required operation, required error}) {
            degradedOperations.add('$operation: $error');
          },
        );
        final failingStore = AttriaxPreferencesRuntimeSettingsStore(
          preferencesStore: failingPreferencesStore,
        );

        final restoredSettings = await failingStore.restore(
          enabledOverride: false,
          eventsEnabledOverride: true,
        );
        await failingStore.setEnabled(enabled: true);
        await failingStore.setEventsEnabled(enabled: false);
        final restoredPersistedSettings = await failingStore.restore();

        expect(restoredSettings.isEnabled, isFalse);
        expect(restoredSettings.areEventsEnabled, isTrue);
        expect(restoredPersistedSettings.isEnabled, isTrue);
        expect(restoredPersistedSettings.areEventsEnabled, isFalse);
        expect(failingPreferencesStore.isPersistenceDegraded, isTrue);
        expect(
          failingPreferencesStore.lastPersistenceFailureOperation,
          'loadPreferences',
        );
        expect(failingPreferencesStore.lastPersistenceError, isA<StateError>());
        expect(degradedOperations, hasLength(1));
      },
    );
  });
}
