import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxPreferencesStore', () {
    late SharedPreferences prefs;
    late AttriaxPreferencesStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      store = AttriaxPreferencesStore(prefsOverride: prefs);
    });

    test('restores runtime preferences and device data separately', () async {
      final restoredRuntime = await store.restoreRuntimePreferences(
        enabledOverride: false,
        eventsEnabledOverride: true,
      );
      final restoredDevice = await store.restoreDeviceData(
        deviceIdFactory: () => 'generated_device',
      );

      expect(restoredRuntime.isEnabled, isFalse);
      expect(restoredRuntime.areEventsEnabled, isTrue);
      expect(restoredDevice.deviceId, 'generated_device');
      expect(restoredDevice.hasPersistedDeviceId, isFalse);
      expect(restoredDevice.isFirstLaunch, isTrue);
      expect(
        prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
        isTrue,
      );
      expect(prefs.getBool(AttriaxPreferencesStore.enabledStorageKey), isFalse);
      expect(
        prefs.getBool(AttriaxPreferencesStore.eventsEnabledStorageKey),
        isTrue,
      );
    });

    test(
      'setResolvedDeviceIdentity persists both device id and source',
      () async {
        await store.setResolvedDeviceIdentity(
          deviceId: 'android_ssaid_device',
          deviceIdSource: 'android_ssaid',
        );

        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          'android_ssaid_device',
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdSourceStorageKey),
          'android_ssaid',
        );
      },
    );

    test(
      'setResolvedDeviceIdentity removes a blank device-id source',
      () async {
        await store.setDeviceIdSource(deviceIdSource: 'android_ssaid');

        await store.setResolvedDeviceIdentity(
          deviceId: 'fallback_device',
          deviceIdSource: '   ',
        );

        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          'fallback_device',
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdSourceStorageKey),
          isNull,
        );
      },
    );

    test('round-trips install referrer details', () async {
      const details = AttriaxInstallReferrerDetails(
        rawPlatformInstallReferrer: 'utm_source=attriax',
        source: 'attriax',
        campaign: 'spring',
        attributionType: AttributionType.referrer,
        precision: 1,
      );

      await store.setInstallReferrerDetails(details: details);

      final restored = await store.readInstallReferrerDetails();

      expect(restored?.rawPlatformInstallReferrer, 'utm_source=attriax');
      expect(restored?.campaign, 'spring');
      expect(restored?.precision, 1);
    });

    test(
      'tracks loaded state for a null structured install referrer',
      () async {
        await store.setStoredInstallReferrerDetails(
          isLoaded: true,
          details: null,
        );

        final restored = await store.readStoredInstallReferrerDetails();

        expect(restored.isLoaded, isTrue);
        expect(restored.value, isNull);
      },
    );

    test('tracks loaded state for a null platform install referrer', () async {
      await store.setStoredPlatformInstallReferrer(isLoaded: true, value: null);

      final restored = await store.readStoredPlatformInstallReferrer();

      expect(restored.isLoaded, isTrue);
      expect(restored.value, isNull);
    });

    test(
      'falls back to in-memory values when preferences loading fails',
      () async {
        final failingStore = AttriaxPreferencesStore(
          preferencesLoader: () async => throw StateError('prefs unavailable'),
        );

        final restoredRuntime = await failingStore.restoreRuntimePreferences(
          enabledOverride: false,
          eventsEnabledOverride: true,
        );
        final restoredDevice = await failingStore.restoreDeviceData(
          deviceIdFactory: () => 'generated_memory_device',
        );

        expect(restoredRuntime.isEnabled, isFalse);
        expect(restoredRuntime.areEventsEnabled, isTrue);
        expect(restoredDevice.deviceId, 'generated_memory_device');
        expect(restoredDevice.isFirstLaunch, isTrue);

        await failingStore.setStoredPlatformInstallReferrer(
          isLoaded: true,
          value: 'utm_source=memory',
        );
        final storedReferrer = await failingStore
            .readStoredPlatformInstallReferrer();
        expect(storedReferrer.isLoaded, isTrue);
        expect(storedReferrer.value, 'utm_source=memory');
      },
    );
  });
}
