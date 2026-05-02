import 'package:attriax/src/internal/attriax_preferences_store.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
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

    test(
      'restore creates the first-launch marker and persists runtime flags',
      () async {
        final restored = await store.restore(
          deviceIdFactory: () => 'generated_device',
          enabledOverride: false,
          eventsEnabledOverride: true,
        );

        expect(restored.deviceId, 'generated_device');
        expect(restored.hasPersistedDeviceId, isFalse);
        expect(restored.isFirstLaunch, isTrue);
        expect(
          prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
          isTrue,
        );
        expect(
          prefs.getBool(AttriaxPreferencesStore.enabledStorageKey),
          isFalse,
        );
        expect(
          prefs.getBool(AttriaxPreferencesStore.eventsEnabledStorageKey),
          isTrue,
        );
      },
    );

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
  });
}
