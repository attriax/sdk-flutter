import 'dart:convert';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attriax consent', () {
    late SharedPreferences prefs;
    late Connectivity connectivity;
    late _FakeConnectivityPlatform connectivityPlatform;
    late _FakeDeepLinkSource deepLinkSource;
    late _ConsentTestContextCollector contextCollector;
    late Attriax sdk;
    late http.Client client;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      connectivityPlatform = _FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      deepLinkSource = _FakeDeepLinkSource();
      contextCollector = _ConsentTestContextCollector();
      client = MockClient((request) async {
        throw StateError(
          'Unexpected request: ${request.method} ${request.url.path}',
        );
      });
      sdk = _createSdk(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          gdprEnabled: true,
        ),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
      );
    });

    tearDown(() async {
      await sdk.dispose();
      await deepLinkSource.dispose();
      await connectivityPlatform.dispose();
      client.close();
    });

    test('needsConsent can resolve locally before init', () async {
      contextCollector.timezone = 'Europe/Berlin';

      final needsConsent = await sdk.consent.gdpr.needsConsent(localOnly: true);

      expect(needsConsent, isTrue);
      expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.pending);
      expect(sdk.consent.gdpr.values, isNull);
      expect(sdk.consent.gdpr.isWaitingForConsent, isTrue);
    });

    test(
      'local-only consent checks refresh unresolved pending state',
      () async {
        contextCollector.timezone = 'Europe/Berlin';

        expect(await sdk.consent.gdpr.needsConsent(localOnly: true), isTrue);
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.pending);

        contextCollector.timezone = 'Europe/Kiev';

        expect(await sdk.consent.gdpr.needsConsent(localOnly: true), isFalse);
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.notRequired);
      },
    );

    test('remote consent checks refresh unresolved pending state', () async {
      var checkCount = 0;
      client = MockClient((request) async {
        if (request.url.path != '/api/sdk/v1/consent/gdpr/check') {
          throw StateError(
            'Unexpected request: ${request.method} ${request.url.path}',
          );
        }

        checkCount += 1;
        return http.Response(
          _gdprEnvelope(<String, Object?>{
            'checkedAt': '2026-05-20T12:00:0$checkCount.000Z',
            'countryCode': checkCount == 1 ? 'DE' : 'UA',
            'needsConsent': checkCount == 1,
            'regionSource': 'ip_country',
            'state': checkCount == 1 ? 'pending' : 'not_required',
          }),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      });
      await sdk.dispose();
      sdk = _createSdk(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          gdprEnabled: true,
        ),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
      );

      expect(await sdk.consent.gdpr.needsConsent(), isTrue);
      expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.pending);

      expect(await sdk.consent.gdpr.needsConsent(), isFalse);
      expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.notRequired);
      expect(checkCount, 2);
    });

    test(
      'needsConsent remains callable when gdpr gating is disabled',
      () async {
        contextCollector.timezone = 'Europe/Berlin';
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(projectToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        final needsConsent = await sdk.consent.gdpr.needsConsent(
          localOnly: true,
        );

        expect(needsConsent, isTrue);
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.pending);
        expect(sdk.consent.gdpr.isWaitingForConsent, isTrue);
      },
    );

    test('setConsent persists locally and syncs to the API', () async {
      contextCollector.timezone = 'Europe/Berlin';
      final requestPaths = <String>[];
      Map<String, Object?>? syncedBody;
      client = MockClient((request) async {
        requestPaths.add(request.url.path);
        if (request.url.path == '/api/sdk/v1/consent/gdpr') {
          syncedBody = jsonDecode(request.body) as Map<String, Object?>;
          return http.Response(
            _gdprEnvelope(<String, Object?>{
              'checkedAt': '2026-05-20T12:00:00.000Z',
              'countryCode': 'DE',
              'needsConsent': false,
              'regionSource': 'manual',
              'state': 'granted',
              'values': <String, Object?>{
                'analytics': true,
                'attribution': false,
                'adEvents': true,
              },
            }),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        }

        throw StateError(
          'Unexpected request: ${request.method} ${request.url.path}',
        );
      });
      await sdk.dispose();
      sdk = _createSdk(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          gdprEnabled: true,
        ),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
      );

      expect(await sdk.consent.gdpr.needsConsent(localOnly: true), isTrue);

      sdk.consent.gdpr.setConsent(
        analytics: true,
        attribution: false,
        adEvents: true,
      );
      await _waitFor(() => syncedBody != null);

      expect(requestPaths, <String>['/api/sdk/v1/consent/gdpr']);
      expect(syncedBody?['state'], 'granted');
      expect(syncedBody?['values'], <String, Object?>{
        'analytics': true,
        'attribution': false,
        'adEvents': true,
      });
      expect(syncedBody?['consentId'], isA<String>());
      expect(syncedBody?['deviceId'], isNull);
      expect(syncedBody?['deviceIdSource'], isNull);
      expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.granted);
      expect(
        sdk.consent.gdpr.values,
        const AttriaxGdprConsentValues(
          analytics: true,
          attribution: false,
          adEvents: true,
        ),
      );

      final secondSdk = _createSdk(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          gdprEnabled: true,
        ),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
      );
      addTearDown(secondSdk.dispose);

      final secondNeedsConsent = await secondSdk.consent.gdpr.needsConsent(
        localOnly: true,
      );

      expect(secondNeedsConsent, isFalse);
      expect(secondSdk.consent.gdpr.state, AttriaxGdprConsentState.granted);
      expect(
        secondSdk.consent.gdpr.values,
        const AttriaxGdprConsentValues(
          analytics: true,
          attribution: false,
          adEvents: true,
        ),
      );
    });

    test(
      'resolved pending consent sends analytics events anonymously before a manual choice',
      () async {
        contextCollector.timezone = 'Europe/Berlin';
        final requestPaths = <String>[];
        final eventBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/events') {
            eventBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        expect(await sdk.consent.gdpr.needsConsent(localOnly: true), isTrue);
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.pending);

        await sdk.init();
        sdk.tracking.recordEvent('purchase');
        await _waitFor(() => eventBodies.isNotEmpty);
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/consent/gdpr')));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);
      },
    );

    test(
      'pending consent buffers analytics until grant when anonymous tracking is disabled',
      () async {
        contextCollector.timezone = 'Europe/Berlin';
        final requestPaths = <String>[];
        final batchBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'DE',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'granted',
                'values': <String, Object?>{
                  'analytics': true,
                  'attribution': false,
                  'adEvents': false,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/batch') {
            batchBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _batchEnvelope(),
              202,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
            anonymousTracking: false,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        expect(sdk.tracking.anonymousTrackingEnabled, isFalse);
        expect(await sdk.consent.gdpr.needsConsent(localOnly: true), isTrue);

        await sdk.init();
        sdk.tracking.recordEvent(
          'purchase',
          eventData: const <String, Object?>{'value': 42},
        );
        await _drainMicrotasks();

        expect(
          requestPaths.where((path) => path != '/api/sdk/v1/config'),
          isEmpty,
        );
        expect(sdk.deviceId, isNull);
        expect(contextCollector.resolvePreferredDeviceIdCalls, 0);
        expect(contextCollector.collectContextSnapshotCalls, 0);
        expect(contextCollector.anonymousSnapshotBuildCalls, 1);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: false,
          adEvents: false,
        );
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/consent/gdpr'));
        await _waitFor(() => batchBodies.isNotEmpty);
        await _waitFor(() => sdk.deviceId == 'device_1');
        await _waitFor(() => sdk.synchronization.isSynchronized);

        final items = batchBodies.single['items']! as List<Object?>;
        final eventItems = items
            .cast<Map<String, Object?>>()
            .where((item) => item['kind'] == 'event')
            .toList(growable: false);
        expect(eventItems, hasLength(1));
        expect(batchBodies.single['deviceId'], 'device_1');
        expect(batchBodies.single['deviceIdSource'], 'test_device');

        final eventBody = eventItems.single['body']! as Map<String, Object?>;
        expect(eventBody['eventName'], 'purchase');
        expect(eventBody.containsKey('deviceId'), isFalse);
        expect(eventBody.containsKey('deviceIdSource'), isFalse);
      },
    );

    test('setNotRequired syncs without device identity fields', () async {
      Map<String, Object?>? syncedBody;
      client = MockClient((request) async {
        if (request.url.path == '/api/sdk/v1/consent/gdpr') {
          syncedBody = jsonDecode(request.body) as Map<String, Object?>;
          return http.Response(
            _gdprEnvelope(<String, Object?>{
              'checkedAt': '2026-05-20T12:00:00.000Z',
              'countryCode': 'UA',
              'needsConsent': false,
              'regionSource': 'manual',
              'state': 'not_required',
            }),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        }

        throw StateError(
          'Unexpected request: ${request.method} ${request.url.path}',
        );
      });
      await sdk.dispose();
      sdk = _createSdk(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          gdprEnabled: true,
        ),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
      );

      sdk.consent.gdpr.setNotRequired();
      await _waitFor(() => syncedBody != null);

      expect(syncedBody?['appToken'], 'ax_test_token');
      expect(syncedBody?['state'], 'not_required');
      expect(syncedBody?['consentId'], isA<String>());
      expect(syncedBody?['values'], isNull);
      expect(syncedBody?['deviceId'], isNull);
      expect(syncedBody?['deviceIdSource'], isNull);
      expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.notRequired);
    });

    test(
      'reset clears persisted consent locally and re-checks remote state after the clear sync',
      () async {
        final requestPaths = <String>[];
        final syncedStates = <String>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);
          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            final body = jsonDecode(request.body) as Map<String, Object?>;
            syncedStates.add(body['state']! as String);
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:00.000Z',
                'needsConsent': true,
                'state': 'unknown',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }
          if (request.url.path == '/api/sdk/v1/consent/gdpr/check') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'UA',
                'needsConsent': false,
                'regionSource': 'ip_country',
                'state': 'not_required',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          throw StateError(
            'Unexpected request: ${request.method} ${request.url.path}',
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        sdk.consent.gdpr.reset();

        await _waitFor(() => syncedStates.length == 1);
        await _waitFor(
          () =>
              !prefs.containsKey(AttriaxPreferencesStore.gdprConsentStorageKey),
        );

        expect(syncedStates, <String>['unknown']);
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.unknown);

        expect(await sdk.consent.gdpr.needsConsent(), isFalse);
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.notRequired);
        expect(requestPaths, <String>[
          '/api/sdk/v1/consent/gdpr',
          '/api/sdk/v1/consent/gdpr/check',
        ]);
      },
    );

    test(
      'requestDataErasure anonymizes remote SDK data and clears local runtime state after success',
      () async {
        final requestPaths = <String>[];
        Map<String, Object?>? syncedConsentBody;
        Map<String, Object?>? erasureBody;
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            syncedConsentBody =
                jsonDecode(request.body) as Map<String, Object?>;
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'DE',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'granted',
                'values': <String, Object?>{
                  'analytics': true,
                  'attribution': true,
                  'adEvents': false,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/privacy/gdpr/erase') {
            erasureBody = jsonDecode(request.body) as Map<String, Object?>;
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-20T12:00:02.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        await _drainMicrotasks();

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: true,
          adEvents: false,
        );
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/open'));
        await _waitFor(() => sdk.synchronization.isSynchronized);

        final storedDeviceId = prefs.getString(
          AttriaxPreferencesStore.deviceIdStorageKey,
        );
        final storedConsentId = prefs.getString(
          AttriaxPreferencesStore.gdprConsentIdStorageKey,
        );

        await sdk.consent.gdpr.requestDataErasure();

        expect(syncedConsentBody?['consentId'], isA<String>());
        expect(erasureBody?['appToken'], 'ax_test_token');
        expect(erasureBody?['deviceId'], storedDeviceId);
        expect(erasureBody?.containsKey('consentId'), isFalse);
        expect(storedConsentId, isNotNull);
        expect(sdk.isInitialized, isFalse);
        expect(
          prefs.containsKey(AttriaxPreferencesStore.deviceIdStorageKey),
          isFalse,
        );
        expect(
          prefs.containsKey(AttriaxPreferencesStore.gdprConsentIdStorageKey),
          isFalse,
        );
        expect(
          prefs.containsKey(AttriaxPreferencesStore.gdprConsentStorageKey),
          isFalse,
        );
      },
    );

    test(
      'init does not auto-detect local consent state without an explicit consent check',
      () async {
        final requestPaths = <String>[];
        final sessionBodies = <Map<String, Object?>>[];
        contextCollector.timezone = 'Europe/Berlin';
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/sessions') {
            sessionBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/config') {
            return http.Response(
              _runtimeConfigEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          throw StateError(
            'Unexpected request during local init: ${request.method} ${request.url.path}',
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        await _waitFor(() => sessionBodies.isNotEmpty);

        expect(requestPaths, contains('/api/sdk/v1/sessions'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/consent/gdpr')));
        expect(requestPaths, isNot(contains('/api/sdk/v1/consent/gdpr/check')));
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.unknown);
        expect(sdk.consent.gdpr.isWaitingForConsent, isTrue);
        expect(sessionBodies.single['deviceId'], isNull);
        expect(sessionBodies.single['deviceIdSource'], isNull);
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          isNull,
        );
        expect(
          prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
          isTrue,
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.sessionSnapshotStorageKey),
          isNull,
        );
      },
    );

    test(
      'init in unknown consent still sends an anonymous session request',
      () async {
        final requestPaths = <String>[];
        final sessionBodies = <Map<String, Object?>>[];
        contextCollector.timezone = 'Europe/Berlin';
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/sessions') {
            sessionBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/config') {
            return http.Response(
              _runtimeConfigEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          throw StateError(
            'Unexpected request during local pending init: ${request.method} ${request.url.path}',
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        await _waitFor(() => sessionBodies.isNotEmpty);

        expect(requestPaths, contains('/api/sdk/v1/sessions'));
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.unknown);
        expect(sdk.deviceId, isNull);
        expect(contextCollector.resolvePreferredDeviceIdCalls, 0);
        expect(contextCollector.collectContextSnapshotCalls, 0);
        expect(contextCollector.anonymousSnapshotBuildCalls, 1);
        expect(sessionBodies.single['deviceId'], isNull);
        expect(sessionBodies.single['deviceIdSource'], isNull);
      },
    );

    test(
      'init in unknown consent state still sends anonymous startup traffic',
      () async {
        final requestPaths = <String>[];
        final sessionBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/sessions') {
            sessionBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'DE',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'granted',
                'values': <String, Object?>{
                  'analytics': true,
                  'attribution': true,
                  'adEvents': false,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-20T12:00:02.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        await _waitFor(() => sessionBodies.isNotEmpty);
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/sessions'));
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.unknown);
        expect(sdk.consent.gdpr.isWaitingForConsent, isTrue);
        expect(sdk.deviceId, isNull);
        expect(contextCollector.resolvePreferredDeviceIdCalls, 0);
        expect(contextCollector.collectContextSnapshotCalls, 0);
        expect(contextCollector.anonymousSnapshotBuildCalls, 1);
        expect(sessionBodies.single['deviceId'], isNull);
        expect(sessionBodies.single['deviceIdSource'], isNull);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: true,
          adEvents: false,
        );
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/open'));
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, isNot(contains('/api/sdk/v1/consent/gdpr/check')));
        expect(requestPaths, contains('/api/sdk/v1/consent/gdpr'));
        expect(requestPaths, contains('/api/sdk/v1/config'));
        expect(requestPaths, contains('/api/sdk/v1/open'));
        expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.granted);
        expect(sdk.deviceId, 'device_1');
        expect(
          contextCollector.resolvePreferredDeviceIdCalls,
          greaterThanOrEqualTo(1),
        );
        expect(
          contextCollector.collectContextSnapshotCalls,
          greaterThanOrEqualTo(1),
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          isNotNull,
        );
        expect(
          prefs.getBool(AttriaxPreferencesStore.firstLaunchSeenStorageKey),
          isTrue,
        );
      },
    );

    test(
      'unknown consent sends analytics events anonymously and syncs consent after grant',
      () async {
        final requestPaths = <String>[];
        final eventBodies = <Map<String, Object?>>[];
        final sessionBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'DE',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'granted',
                'values': <String, Object?>{
                  'analytics': true,
                  'attribution': false,
                  'adEvents': true,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/events') {
            eventBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/sessions') {
            sessionBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-20T12:00:02.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        await _waitFor(() => sessionBodies.isNotEmpty);
        sdk.tracking.recordEvent(
          'purchase',
          eventData: const <String, Object?>{'value': 42},
        );
        await _waitFor(() => eventBodies.isNotEmpty);
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(requestPaths, contains('/api/sdk/v1/sessions'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/consent/gdpr')));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);

        sdk.consent.gdpr.setConsent(
          analytics: true,
          attribution: false,
          adEvents: true,
        );
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/consent/gdpr'));
        await _waitFor(
          () => sdk.consent.gdpr.state == AttriaxGdprConsentState.granted,
        );
        await _waitFor(() => sdk.synchronization.isSynchronized);
        await _drainMicrotasks();

        expect(requestPaths, contains('/api/sdk/v1/consent/gdpr'));
        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(requestPaths, contains('/api/sdk/v1/sessions'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/batch')));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);
      },
    );

    test(
      'unknown consent sends analytics events anonymously before GDPR is not required',
      () async {
        final requestPaths = <String>[];
        final eventBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'US',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'not_required',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/events') {
            eventBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-20T12:00:02.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        sdk.tracking.recordEvent('purchase');
        await _waitFor(() => eventBodies.isNotEmpty);
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);

        sdk.consent.gdpr.setNotRequired();
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/consent/gdpr'));
        await _waitFor(
          () => sdk.consent.gdpr.state == AttriaxGdprConsentState.notRequired,
        );
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/consent/gdpr'));
        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);
      },
    );

    test(
      'unknown consent sends analytics events anonymously before denial',
      () async {
        final requestPaths = <String>[];
        final eventBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'DE',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'granted',
                'values': <String, Object?>{
                  'analytics': false,
                  'attribution': false,
                  'adEvents': false,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/events') {
            eventBodies.add(jsonDecode(request.body) as Map<String, Object?>);
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        sdk.tracking.recordEvent('purchase');
        await _waitFor(() => eventBodies.isNotEmpty);
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);

        sdk.consent.gdpr.setConsent(
          analytics: false,
          attribution: false,
          adEvents: false,
        );
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/consent/gdpr'));
        await _waitFor(
          () => sdk.consent.gdpr.state == AttriaxGdprConsentState.granted,
        );
        await _waitFor(() => sdk.synchronization.isSynchronized);
        await _drainMicrotasks();

        expect(requestPaths, contains('/api/sdk/v1/consent/gdpr'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/batch')));
        expect(requestPaths, contains('/api/sdk/v1/events'));
        expect(eventBodies.single['eventName'], 'purchase');
        expect(eventBodies.single['deviceId'], isNull);
        expect(eventBodies.single['deviceIdSource'], isNull);
        expect(
          prefs.containsKey(AttriaxPreferencesStore.deviceIdStorageKey),
          isFalse,
        );
        expect(
          prefs.containsKey(AttriaxPreferencesStore.sessionSnapshotStorageKey),
          isFalse,
        );
      },
    );

    test(
      'pending consent does not capture uninstall tokens before attribution grant',
      () async {
        final requestPaths = <String>[];
        Map<String, Object?>? uninstallBody;
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/consent/gdpr') {
            return http.Response(
              _gdprEnvelope(<String, Object?>{
                'checkedAt': '2026-05-20T12:00:01.000Z',
                'countryCode': 'DE',
                'needsConsent': false,
                'regionSource': 'manual',
                'state': 'granted',
                'values': <String, Object?>{
                  'analytics': false,
                  'attribution': true,
                  'adEvents': false,
                },
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/uninstall-tokens') {
            uninstallBody = jsonDecode(request.body) as Map<String, Object?>;
            return http.Response(
              _ackEnvelope(),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-20T12:00:02.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            request.url.path == '/api/sdk/v1/config'
                ? _runtimeConfigEnvelope()
                : _ackEnvelope(),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        await sdk.dispose();
        sdk = _createSdk(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            gdprEnabled: true,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
        );

        await sdk.init();
        await sdk.tracking.registerApplePushToken('apns_token_1');
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/sessions'));
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/sessions'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/uninstall-tokens')));

        sdk.consent.gdpr.setConsent(
          analytics: false,
          attribution: true,
          adEvents: false,
        );
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/consent/gdpr'));
        await _waitFor(() => requestPaths.contains('/api/sdk/v1/open'));
        await _waitFor(() => sdk.synchronization.isSynchronized);

        expect(requestPaths, contains('/api/sdk/v1/consent/gdpr'));
        expect(requestPaths, contains('/api/sdk/v1/open'));
        expect(requestPaths, isNot(contains('/api/sdk/v1/uninstall-tokens')));
        expect(uninstallBody, isNull);
      },
    );

    test('needsConsent can resolve from the API before init', () async {
      final requestPaths = <String>[];
      client = MockClient((request) async {
        requestPaths.add(request.url.path);
        if (request.url.path == '/api/sdk/v1/consent/gdpr/check') {
          return http.Response(
            _gdprEnvelope(<String, Object?>{
              'checkedAt': '2026-05-20T12:00:00.000Z',
              'countryCode': 'US',
              'needsConsent': false,
              'regionSource': 'geo_ip',
              'state': 'not_required',
            }),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        }

        throw StateError(
          'Unexpected request: ${request.method} ${request.url.path}',
        );
      });
      await sdk.dispose();
      sdk = _createSdk(
        config: const AttriaxConfig(
          projectToken: 'ax_test_token',
          gdprEnabled: true,
        ),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
      );

      final needsConsent = await sdk.consent.gdpr.needsConsent();

      expect(needsConsent, isFalse);
      expect(requestPaths, <String>['/api/sdk/v1/consent/gdpr/check']);
      expect(sdk.consent.gdpr.state, AttriaxGdprConsentState.notRequired);
      expect(sdk.consent.gdpr.isWaitingForConsent, isFalse);
    });
  });
}

class _ConsentTestContextCollector extends AttriaxContextCollector {
  _ConsentTestContextCollector()
    : platform = AttriaxPlatformType.ios,
      super(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        platformType: AttriaxPlatformType.ios,
      );

  String? timezone;
  final AttriaxPlatformType platform;
  int resolvePreferredDeviceIdCalls = 0;
  int collectContextSnapshotCalls = 0;
  int anonymousSnapshotBuildCalls = 0;

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async {
    resolvePreferredDeviceIdCalls += 1;
    return const AttriaxResolvedDeviceId(
      value: 'device_1',
      source: 'test_device',
    );
  }

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
    bool waitForTrackingAuthorization = false,
  }) async {
    collectContextSnapshotCalls += 1;
    return AttriaxContextSnapshot(
      platform: platform,
      deviceId: deviceId,
      isFirstLaunch: isFirstLaunch,
      sdk: const AttriaxSdkSnapshot(
        apiVersion: attriaxSdkApiVersion,
        packageVersion: attriaxSdkPackageVersion,
      ),
      app: const AttriaxAppSnapshot(
        version: '1.0.0',
        buildNumber: '1',
        packageName: 'com.attriax.test',
      ),
      device: const AttriaxDeviceSnapshot(model: 'Pixel', osVersion: '14'),
    );
  }

  @override
  AttriaxContextSnapshot buildAnonymousStartupSnapshot({
    required bool isFirstLaunch,
    String? timezone,
  }) {
    anonymousSnapshotBuildCalls += 1;
    return AttriaxContextSnapshot(
      platform: platform,
      deviceId: null,
      isFirstLaunch: isFirstLaunch,
      sdk: const AttriaxSdkSnapshot(
        apiVersion: attriaxSdkApiVersion,
        packageVersion: attriaxSdkPackageVersion,
      ),
      app: const AttriaxAppSnapshot(
        version: '1.0.0',
        buildNumber: '1',
        packageName: 'com.attriax.test',
      ),
      device: AttriaxDeviceSnapshot(timezone: timezone),
    );
  }

  @override
  Future<String?> resolveDeviceTimezone() async => timezone;
}

class _FakeDeepLinkSource implements AttriaxDeepLinkSource {
  Uri? initialLink;

  @override
  Future<Uri?> getInitialLink() async => initialLink;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();

  Future<void> dispose() async {}
}

class _FakeConnectivityPlatform extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      <ConnectivityResult>[ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();

  Future<void> dispose() async {}
}

String _sdkEnvelope(Map<String, Object?> data) => jsonEncode(<String, Object?>{
  'success': true,
  'timestamp': '2026-05-20T12:00:00.000Z',
  'data': data,
});

String _ackEnvelope() => _sdkEnvelope(<String, Object?>{'success': true});

String _batchEnvelope() => _sdkEnvelope(<String, Object?>{
  'acceptedAt': '2026-05-20T12:00:02.000Z',
  'duplicateCount': 0,
  'itemCount': 2,
  'processedCount': 2,
  'requestVersion': 'v1',
});

String _runtimeConfigEnvelope() => _sdkEnvelope(<String, Object?>{
  'acceptedAt': '2026-05-20T12:00:01.000Z',
  'clipboardAttributionEnabled': false,
  'requestVersion': 'v1',
});

String _gdprEnvelope(Map<String, Object?> data) => jsonEncode(<String, Object?>{
  'success': true,
  'timestamp': '2026-05-20T12:00:00.000Z',
  'data': data,
});

Future<void> _drainMicrotasks() async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 50; attempt += 1) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }

  throw StateError('Timed out while waiting for asynchronous consent work.');
}

Attriax _createSdk({
  required AttriaxConfig config,
  required http.Client client,
  required AttriaxDeepLinkSource deepLinkSource,
  required Connectivity connectivity,
  required AttriaxContextCollector contextCollector,
  required SharedPreferences prefs,
}) => Attriax.test(
  config: config,
  client: client,
  deepLinkSource: deepLinkSource,
  connectivity: connectivity,
  contextCollector: contextCollector,
  prefs: prefs,
  enableDebugLogs: false,
);
