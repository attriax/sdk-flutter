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
      'ensuring device identity does not consume the first-launch marker',
      () async {
        final restoredIdentity = await store.ensureDeviceIdentity(
          deviceIdFactory: () => 'generated_device',
        );

        expect(restoredIdentity.deviceId, 'generated_device');
        expect(restoredIdentity.hasPersistedDeviceId, isFalse);
        expect(
          prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
          isNull,
        );

        final restoredDevice = await store.restoreDeviceData(
          deviceIdFactory: () => 'unused_device',
        );

        expect(restoredDevice.deviceId, 'generated_device');
        expect(restoredDevice.isFirstLaunch, isTrue);
        expect(
          prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
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

    test('round-trips reinstall referrer details', () async {
      const details = AttriaxInstallReferrerDetails(
        rawPlatformInstallReferrer: 'utm_source=reattribution',
        source: 'reattribution',
        campaign: 'returning_user',
        attributionType: AttributionType.referrer,
        precision: 1,
      );

      await store.setReinstallReferrerDetails(details: details);

      final restored = await store.readReinstallReferrerDetails();

      expect(restored?.rawPlatformInstallReferrer, 'utm_source=reattribution');
      expect(restored?.campaign, 'returning_user');
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

    test('tracks loaded state for a null reinstall referrer', () async {
      await store.setStoredReinstallReferrerDetails(
        isLoaded: true,
        details: null,
      );

      final restored = await store.readStoredReinstallReferrerDetails();

      expect(restored.isLoaded, isTrue);
      expect(restored.value, isNull);
    });

    test('tracks deferred app-open deep-link handling', () async {
      expect(await store.readDeferredAppOpenDeepLinkHandled(), isFalse);

      await store.setDeferredAppOpenDeepLinkHandled(value: true);

      expect(await store.readDeferredAppOpenDeepLinkHandled(), isTrue);
    });

    test('round-trips SKAN state', () async {
      final now = DateTime.utc(2026, 5, 15, 12, 30);
      final state = AttriaxSkanState(
        enabled: true,
        schemaVersion: 4,
        schema: AttriaxSkanSchema(
          version: 4,
          updatedAt: now,
          window1: const AttriaxSkanWindow1(
            groups: <AttriaxSkanWindow1Group>[
              AttriaxSkanWindow1Group(
                id: 'group_purchase',
                startBit: 4,
                bitCount: 2,
                events: <AttriaxSkanEvent>[
                  AttriaxSkanEvent(
                    id: 'event_purchase',
                    eventName: 'purchase',
                    coarseValue: AttriaxSkanCoarseValue.medium,
                    lockWindow: true,
                  ),
                ],
              ),
            ],
          ),
          window2: const AttriaxSkanCoarseWindow(
            events: <AttriaxSkanCoarseWindowEvent>[
              AttriaxSkanCoarseWindowEvent(
                id: 'retention_day_7',
                eventName: '_attriax_retention',
                coarseValue: AttriaxSkanCoarseValue.medium,
                conditions: <AttriaxSkanCondition>[
                  AttriaxSkanCondition(
                    id: 'condition_day',
                    paramKey: 'day',
                    value: 7,
                  ),
                ],
              ),
            ],
          ),
        ),
        fineValue: 24,
        coarseValue: AttriaxSkanCoarseValue.medium,
        lockWindow: true,
        firstLaunchValueRegistered: true,
        lastUpdatedAt: now,
        installAnchorAt: now.subtract(const Duration(days: 1)),
        completedRetentionDays: const <int>[1],
        purchaseRevenueUsdMicros: 2500000,
        purchaseCount: 2,
        adShowCount: 5,
      );

      await store.setSkanState(state: state);

      final restored = await store.readSkanState();

      expect(restored?.enabled, isTrue);
      expect(restored?.schemaVersion, 4);
      expect(restored?.schema?.window1.groups.single.startBit, 4);
      expect(
        restored?.schema?.window1.groups.single.events.single.eventName,
        'purchase',
      );
      expect(
        restored?.schema?.window1.groups.single.events.single.coarseValue,
        AttriaxSkanCoarseValue.medium,
      );
      expect(
        restored?.schema?.window1.groups.single.events.single.lockWindow,
        isTrue,
      );
      expect(
        restored?.schema?.window2.events.single.eventName,
        '_attriax_retention',
      );
      expect(restored?.fineValue, 24);
      expect(restored?.coarseValue, AttriaxSkanCoarseValue.medium);
      expect(restored?.lockWindow, isTrue);
      expect(restored?.firstLaunchValueRegistered, isTrue);
      expect(restored?.lastUpdatedAt, now);
      expect(restored?.installAnchorAt, now.subtract(const Duration(days: 1)));
      expect(restored?.completedRetentionDays, const <int>[1]);
      expect(restored?.purchaseRevenueUsdMicros, 2500000);
      expect(restored?.purchaseCount, 2);
      expect(restored?.adShowCount, 5);

      await store.setSkanState(state: null);

      expect(await store.readSkanState(), isNull);
    });

    test(
      'falls back to in-memory values when preferences loading fails',
      () async {
        final degradedOperations = <String>[];
        final failingStore = AttriaxPreferencesStore(
          preferencesLoader: () async => throw StateError('prefs unavailable'),
          onPersistenceDegraded: ({required operation, required error}) {
            degradedOperations.add('$operation: $error');
          },
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
        expect(failingStore.isPersistenceDegraded, isTrue);
        expect(failingStore.lastPersistenceFailureOperation, 'loadPreferences');
        expect(failingStore.lastPersistenceError, isA<StateError>());
        expect(degradedOperations, hasLength(1));
      },
    );
  });
}
