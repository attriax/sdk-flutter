import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_api_client/attriax_api_client.dart' as generated_sdk;
import 'package:built_value/serializer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attriax.init', () {
    late FakeDeepLinkSource deepLinkSource;
    late Connectivity connectivity;
    late FakeConnectivityPlatform connectivityPlatform;
    late CountingContextCollector contextCollector;
    late SharedPreferences prefs;
    late http.Client client;
    late Attriax sdk;
    late AttriaxPlatform originalPlatform;

    setUp(() async {
      originalPlatform = AttriaxPlatform.instance;
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      deepLinkSource = FakeDeepLinkSource();
      connectivityPlatform = FakeConnectivityPlatform();
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      contextCollector = CountingContextCollector();
      client = http.Client();
      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );
    });

    tearDown(() async {
      AttriaxPlatform.instance = originalPlatform;
      await sdk.dispose();
      await deepLinkSource.dispose();
      await connectivityPlatform.dispose();
      client.close();
    });

    test(
      'shares a single initialization pass across concurrent callers',
      () async {
        await Future.wait(<Future<void>>[sdk.init(), sdk.init(), sdk.init()]);

        expect(sdk.isInitialized, isTrue);
        expect(contextCollector.collectContextSnapshotCalls, 1);
        expect(deepLinkSource.getInitialLinkCalls, 1);
      },
    );

    test('treats repeated init calls after success as a no-op', () async {
      await sdk.init();
      await sdk.init();

      expect(contextCollector.collectContextSnapshotCalls, 1);
      expect(deepLinkSource.getInitialLinkCalls, 1);
    });

    test(
      'treats a legacy stored device id as persistent storage and does not re-resolve',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          AttriaxPreferencesStore.deviceIdStorageKey: 'sdk_fallback_device',
        });
        prefs = await SharedPreferences.getInstance();
        contextCollector = CountingContextCollector();
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        expect(sdk.sdkSnapshot, isNotNull);
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          'sdk_fallback_device',
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdSourceStorageKey),
          attriaxPersistentStorageDeviceIdSource,
        );
        expect(contextCollector.resolvePreferredDeviceIdCalls, 0);
        expect(contextCollector.collectedContextDeviceIds, <String>[
          'sdk_fallback_device',
        ]);
      },
    );

    test(
      'persists the resolved platform-derived device id and source',
      () async {
        contextCollector = CountingContextCollector()
          ..resolvedDeviceId = const AttriaxResolvedDeviceId(
            value: 'android_ssaid_device',
            source: 'android_ssaid',
          );
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
          'android_ssaid_device',
        );
        expect(
          prefs.getString(AttriaxPreferencesStore.deviceIdSourceStorageKey),
          'android_ssaid',
        );
        expect(contextCollector.resolvePreferredDeviceIdCalls, 1);
        expect(contextCollector.collectedContextDeviceIds, <String>[
          'android_ssaid_device',
        ]);
      },
    );

    test(
      'imports pending native crash reports during init and clears retry storage after ack',
      () async {
        final crashPlatform = FakeCrashReportingPlatform(
          pendingCrashReport: AttriaxPendingCrashReport(
            source: 'android_uncaught_exception',
            isFatal: true,
            exceptionType: 'java.lang.IllegalStateException',
            message: 'boom',
            stackTrace: 'native stack',
            occurredAt: DateTime.utc(2026, 5, 4, 10, 0),
            metadata: <String, Object?>{'threadName': 'main'},
          ),
        );
        AttriaxPlatform.instance = crashPlatform;
        final crashRequest = Completer<Map<String, Object?>>();
        client = MockClient((request) async {
          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-06T10:00:00.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          expect(request.url.path, '/api/sdk/v1/crashes');
          crashRequest.complete(
            jsonDecode(request.body) as Map<String, Object?>,
          );
          return http.Response(
            jsonEncode(<String, Object?>{
              'data': <String, Object?>{'success': true},
            }),
            202,
            headers: <String, String>{'content-type': 'application/json'},
          );
        });
        contextCollector = CountingContextCollector();
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        final body = await crashRequest.future;
        expect(body['source'], 'android_uncaught_exception');
        expect(body['message'], 'boom');
        expect(body['exceptionType'], 'java.lang.IllegalStateException');
        expect(crashPlatform.consumePendingCrashReportCalls, 1);

        for (var attempt = 0; attempt < 10; attempt += 1) {
          if (prefs.getString(
                AttriaxPreferencesStore.pendingCrashReportStorageKey,
              ) ==
              null) {
            break;
          }
          await Future<void>.delayed(Duration.zero);
        }

        expect(
          prefs.getString(AttriaxPreferencesStore.pendingCrashReportStorageKey),
          isNull,
        );
      },
    );

    test(
      'init stays fast while queued work waits for delayed app-open scheduling',
      () async {
        final delayedPlatform = DelayedInstallReferrerPlatform();
        AttriaxPlatform.instance = delayedPlatform;
        contextCollector = CountingContextCollector();
        final requestPaths = <String>[];
        final batchBodies = <Map<String, Object?>>[];
        client = MockClient((request) async {
          requestPaths.add(request.url.path);

          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-06T10:00:00.000Z',
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
              jsonEncode(
                _serializeGenerated(
                  generated_sdk.SdkV1BatchResponseEnvelopeDto.serializer,
                  _batchEnvelope(),
                ),
              ),
              202,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          return http.Response(
            _sdkEnvelope(<String, Object?>{'success': true}),
            200,
            headers: const <String, String>{'content-type': 'application/json'},
          );
        });
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init().timeout(const Duration(milliseconds: 200));
        await sdk.recordEvent(
          'purchase',
          eventData: const <String, Object?>{'value': 42},
        );
        await _flushRuntimeTransitions();

        expect(requestPaths, isEmpty);

        delayedPlatform.complete(
          const AttriaxInstallReferrerContext(
            installReferrer: 'utm_source=attriax&utm_campaign=delayed',
          ),
        );
        await _flushRuntimeTransitions();

        expect(requestPaths, <String>['/api/sdk/v1/open', '/api/sdk/v1/batch']);
        expect(batchBodies, hasLength(1));

        final items = batchBodies.single['items']! as List<Object?>;
        expect(items, hasLength(1));
        final item = items.single! as Map<String, Object?>;
        expect(item['kind'], 'event');
      },
    );

    test(
      'queues app open before replaying pending crash reports during init',
      () async {
        final crashPlatform = FakeCrashReportingPlatform(
          pendingCrashReport: AttriaxPendingCrashReport(
            source: 'android_uncaught_exception',
            isFatal: true,
            exceptionType: 'java.lang.IllegalStateException',
            message: 'boom',
            stackTrace: 'native stack',
            occurredAt: DateTime.utc(2026, 5, 4, 10, 0),
          ),
        );
        AttriaxPlatform.instance = crashPlatform;
        contextCollector = CountingContextCollector();
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        await _flushRuntimeTransitions();

        final queued = _queuedEntriesFromPrefs(prefs);
        expect(queued, hasLength(2));
        expect(
          queued.map((entry) => entry['kind']),
          containsAll(<String>['open', 'trackCrash']),
        );
      },
    );

    test(
      'persists fatal platform dispatcher errors for the next launch',
      () async {
        await sdk.init();

        final handled = ui.PlatformDispatcher.instance.onError?.call(
          StateError('boom'),
          StackTrace.fromString('stack line'),
        );

        expect(handled, isFalse);
        await Future<void>.delayed(Duration.zero);
        final raw = prefs.getString(
          AttriaxPreferencesStore.pendingCrashReportStorageKey,
        );
        expect(raw, isNotNull);

        final body = jsonDecode(raw!) as Map<String, Object?>;
        expect(body['source'], 'platform_dispatcher');
        expect(body['isFatal'], isTrue);
        expect(body['message'], 'Bad state: boom');
        expect(body['stackTrace'], 'stack line');
      },
    );

    test(
      'does not install or replay automatic crash reporting when disabled',
      () async {
        final previousFlutterErrorHandler = FlutterError.onError;
        final previousPlatformErrorHandler =
            ui.PlatformDispatcher.instance.onError;
        final crashPlatform = FakeCrashReportingPlatform(
          pendingCrashReport: AttriaxPendingCrashReport(
            source: 'android_uncaught_exception',
            isFatal: true,
            exceptionType: 'java.lang.IllegalStateException',
            message: 'boom',
            stackTrace: 'native stack',
            occurredAt: DateTime.utc(2026, 5, 4, 10, 0),
          ),
        );
        AttriaxPlatform.instance = crashPlatform;
        contextCollector = CountingContextCollector();
        sdk = Attriax.test(
          config: const AttriaxConfig(
            appToken: 'ax_test_token',
            automaticCrashReportingEnabled: false,
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        expect(FlutterError.onError, same(previousFlutterErrorHandler));
        expect(
          ui.PlatformDispatcher.instance.onError,
          same(previousPlatformErrorHandler),
        );
        expect(crashPlatform.consumePendingCrashReportCalls, 0);
        expect(crashPlatform.automaticCrashReportingValues, <bool>[false]);
      },
    );

    test('creates and persists a current session snapshot', () async {
      final now = DateTime.utc(2026, 5, 3, 12, 0);
      final clock = AttriaxMutableClock(now);
      sdk = Attriax.test(
        config: AttriaxConfig(appToken: 'ax_test_token', clock: clock),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init();

      final session = _storedSessionSnapshot(prefs);
      expect(session, isNotNull);
      expect(session!.deviceId, sdk.deviceId);
      expect(session.platform, AttriaxPlatformType.android);
      expect(session.startedAt, now);
      expect(session.lastActivityAt, now);
      expect(session.heartbeatInterval, const Duration(seconds: 5));
    });

    test('restores the current session while it is still active', () async {
      final now = DateTime.utc(2026, 5, 3, 12, 0);
      final firstClock = AttriaxMutableClock(now);
      sdk = Attriax.test(
        config: AttriaxConfig(appToken: 'ax_test_token', clock: firstClock),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init();
      final initialSession = _storedSessionSnapshot(prefs);
      expect(initialSession, isNotNull);

      final secondDeepLinkSource = FakeDeepLinkSource();
      final secondClient = http.Client();
      final secondContextCollector = CountingContextCollector();
      final secondSdk = Attriax.test(
        config: AttriaxConfig(
          appToken: 'ax_test_token',
          clock: AttriaxMutableClock(now.add(const Duration(seconds: 5))),
        ),
        client: secondClient,
        deepLinkSource: secondDeepLinkSource,
        connectivity: connectivity,
        contextCollector: secondContextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await secondSdk.init();

      final restoredSession = _storedSessionSnapshot(prefs);
      expect(restoredSession, isNotNull);
      expect(restoredSession!.id, initialSession!.id);
      expect(restoredSession.startedAt, initialSession.startedAt);
      expect(
        restoredSession.lastActivityAt,
        now.add(const Duration(seconds: 5)),
      );

      await secondSdk.dispose();
      await secondDeepLinkSource.dispose();
      secondClient.close();
    });

    test(
      'starts a new session after the continuation window expires',
      () async {
        final now = DateTime.utc(2026, 5, 3, 12, 0);
        final firstClock = AttriaxMutableClock(now);
        sdk = Attriax.test(
          config: AttriaxConfig(appToken: 'ax_test_token', clock: firstClock),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        final initialSession = _storedSessionSnapshot(prefs);
        expect(initialSession, isNotNull);

        final secondDeepLinkSource = FakeDeepLinkSource();
        final secondClient = http.Client();
        final secondContextCollector = CountingContextCollector();
        final secondSdk = Attriax.test(
          config: AttriaxConfig(
            appToken: 'ax_test_token',
            clock: AttriaxMutableClock(now.add(const Duration(seconds: 11))),
          ),
          client: secondClient,
          deepLinkSource: secondDeepLinkSource,
          connectivity: connectivity,
          contextCollector: secondContextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await secondSdk.init();

        final newSession = _storedSessionSnapshot(prefs);
        expect(newSession, isNotNull);
        expect(newSession!.id, isNot(initialSession!.id));
        expect(newSession.startedAt, now.add(const Duration(seconds: 11)));

        await secondSdk.dispose();
        await secondDeepLinkSource.dispose();
        secondClient.close();
      },
    );

    test('queues track events with the active session metadata', () async {
      var now = DateTime.utc(2026, 5, 3, 12, 0);
      final clock = AttriaxMutableClock(now);
      connectivityPlatform = FakeConnectivityPlatform(
        currentResults: const <ConnectivityResult>[ConnectivityResult.none],
      );
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      sdk = Attriax.test(
        config: AttriaxConfig(appToken: 'ax_test_token', clock: clock),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init();
      final session = _storedSessionSnapshot(prefs);
      expect(session, isNotNull);

      now = now.add(const Duration(seconds: 7));
      clock.currentTime = now;
      await sdk.recordEvent(
        'purchase',
        eventData: const <String, Object?>{'value': 42},
      );

      final bodies = _queuedBodiesFromPrefs(prefs);
      expect(bodies, hasLength(1));

      final body = bodies.single;
      expect(body['eventName'], 'purchase');
      expect(body['sessionId'], session!.id);
      expect(body['sessionRelativeTimeMs'], 7000);
      expect(body['clientOccurredAt'], now.toIso8601String());
    });

    test(
      'recordPurchase queues a normalized purchase revenue payload',
      () async {
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        await sdk.recordPurchase(
          revenue: 4.99,
          currency: 'usd',
          productId: 'coins_500',
          transactionId: 'txn_123',
          validationProvider: 'google_play',
          purchaseToken: 'purchase-token-123',
          isRenewal: false,
          quantity: 2,
          metadata: const <String, Object?>{'placement': 'paywall'},
        );

        final bodies = _queuedBodiesFromPrefs(prefs);
        expect(bodies, hasLength(1));

        final body = bodies.single;
        final eventData = body['eventData']! as Map<String, Object?>;

        expect(body['eventName'], 'purchase');
        expect(eventData['revenue'], 4.99);
        expect(eventData['currency'], 'USD');
        expect(eventData['productId'], 'coins_500');
        expect(eventData['transactionId'], 'txn_123');
        expect(eventData['validationProvider'], 'google_play');
        expect(eventData['purchaseToken'], 'purchase-token-123');
        expect(eventData['isRenewal'], isFalse);
        expect(eventData['quantity'], 2);
        expect(eventData['placement'], 'paywall');
      },
    );

    test(
      'recordPurchase falls back to 0 USD for an invalid currency',
      () async {
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        await sdk.recordPurchase(revenue: 4.99, currency: '  ');

        final bodies = _queuedBodiesFromPrefs(prefs);
        expect(bodies, hasLength(1));

        final body = bodies.single;
        final eventData = body['eventData']! as Map<String, Object?>;

        expect(body['eventName'], 'purchase');
        expect(eventData['revenue'], 0);
        expect(eventData['currency'], 'USD');
      },
    );

    test('recordRefund queues a normalized refund revenue payload', () async {
      connectivityPlatform = FakeConnectivityPlatform(
        currentResults: const <ConnectivityResult>[ConnectivityResult.none],
      );
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init();
      await sdk.recordRefund(
        revenue: 4.99,
        currency: 'eur',
        transactionId: 'refund_txn_123',
        originalTransactionId: 'txn_123',
        productId: 'coins_500',
        quantity: 2,
        test: true,
        reason: 'chargeback',
      );

      final bodies = _queuedBodiesFromPrefs(prefs);
      expect(bodies, hasLength(1));

      final body = bodies.single;
      final eventData = body['eventData']! as Map<String, Object?>;

      expect(body['eventName'], 'refund');
      expect(eventData['revenue'], -4.99);
      expect(eventData['currency'], 'EUR');
      expect(eventData['revenueType'], 'refund');
      expect(eventData['productId'], 'coins_500');
      expect(eventData['transactionId'], 'refund_txn_123');
      expect(eventData['originalTransactionId'], 'txn_123');
      expect(eventData['quantity'], 2);
      expect(eventData['test'], isTrue);
      expect(eventData.containsKey('refundEventId'), isFalse);
      expect(eventData['reason'], 'chargeback');
    });

    test(
      'validateReceipt posts directly and returns the public result',
      () async {
        client = MockClient((request) async {
          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-06T10:00:00.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          expect(request.url.path, '/api/sdk/v1/revenue/receipts/validate');

          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['appToken'], 'ax_test_token');
          expect(body['provider'], 'unity');
          expect(body['productId'], 'coins_500');
          expect(body['purchaseToken'], 'purchase-token-123');

          return http.Response(
            jsonEncode(<String, Object?>{
              'success': true,
              'timestamp': '2026-05-06T10:00:00.000Z',
              'data': <String, Object?>{
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-06T10:00:00.000Z',
                'validationId': 'validation_1',
                'status': 'passthrough',
                'provider': 'unity',
                'productId': 'coins_500',
                'providerResult': <String, Object?>{
                  'provider': 'unity',
                  'unityReceipt': <String, Object?>{
                    'store': 'google_play',
                    'transactionId': 'unity_txn_1',
                  },
                },
                'publicReceipt': <String, Object?>{
                  'provider': 'unity',
                  'unityReceipt': <String, Object?>{
                    'store': 'google_play',
                    'transactionId': 'unity_txn_1',
                  },
                },
              },
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        });

        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        final result = await sdk.validateReceipt(
          provider: 'unity',
          productId: 'coins_500',
          purchaseToken: 'purchase-token-123',
          receiptData:
              '{"Store":"GooglePlay","TransactionID":"unity_txn_1","Payload":"{}"}',
        );

        expect(
          result.status,
          AttriaxRevenueReceiptValidationStatus.passthrough,
        );
        expect(result.validationId, 'validation_1');
        expect(result.provider, 'unity');
        expect(result.productId, 'coins_500');
        expect(result.publicReceipt['provider'], 'unity');
      },
    );

    test('recordAdRevenue queues a normalized ad revenue payload', () async {
      connectivityPlatform = FakeConnectivityPlatform(
        currentResults: const <ConnectivityResult>[ConnectivityResult.none],
      );
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init();
      await sdk.recordAdRevenue(
        revenue: 120000,
        revenueInMicros: true,
        adNetwork: 'admob',
        adFormat: 'rewarded',
        adPlacement: 'level_end',
      );

      final bodies = _queuedBodiesFromPrefs(prefs);
      expect(bodies, hasLength(1));

      final body = bodies.single;
      final eventData = body['eventData']! as Map<String, Object?>;

      expect(body['eventName'], 'ad_revenue');
      expect(eventData['revenue'], 120000);
      expect(eventData['revenueInMicros'], isTrue);
      expect(eventData['currency'], 'USD');
      expect(eventData['adNetwork'], 'admob');
      expect(eventData['adFormat'], 'rewarded');
      expect(eventData['adPlacement'], 'level_end');
    });

    test('reset clears sdk-owned state and allows a fresh init', () async {
      connectivityPlatform = FakeConnectivityPlatform(
        currentResults: const <ConnectivityResult>[ConnectivityResult.none],
      );
      ConnectivityPlatform.instance = connectivityPlatform;
      connectivity = Connectivity();
      sdk = Attriax.test(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        client: client,
        deepLinkSource: deepLinkSource,
        connectivity: connectivity,
        contextCollector: contextCollector,
        prefs: prefs,
        enableDebugLogs: false,
      );

      await sdk.init();
      final firstDeviceId = sdk.deviceId;
      expect(firstDeviceId, isNotNull);

      await sdk.recordEvent('stale_event');
      expect(
        _queuedBodiesFromPrefs(prefs).map((body) => body['eventName']),
        contains('stale_event'),
      );

      await sdk.reset();

      expect(sdk.isInitialized, isFalse);
      expect(sdk.deviceId, isNull);
      expect(
        prefs.getString(AttriaxPreferencesStore.deviceIdStorageKey),
        isNull,
      );

      await sdk.init();

      expect(sdk.isInitialized, isTrue);
      expect(sdk.isFirstLaunch, isTrue);
      expect(sdk.deviceId, isNot(equals(firstDeviceId)));
      final queuedRaw = prefs.getString(
        AttriaxPreferencesStore.queueStorageKey,
      );
      if (queuedRaw != null && queuedRaw.isNotEmpty) {
        expect(
          _queuedBodiesFromPrefs(
            prefs,
          ).map((body) => body['eventName']).contains('stale_event'),
          isFalse,
        );
      }
    });

    test(
      'registerFirebaseMessagingToken sends the uninstall-token payload',
      () async {
        client = MockClient((request) async {
          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-06T10:00:00.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          expect(request.method, 'POST');
          expect(request.url.path, '/api/sdk/v1/uninstall-tokens');

          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['appToken'], 'ax_test_token');
          expect(body['deviceId'], isNotEmpty);
          expect(body['deviceIdSource'], isNotEmpty);
          expect(body['platform'], 'android');
          expect(body['provider'], 'fcm');
          expect(body['token'], 'fcm_token_123');
          expect(body['metadata'], <String, Object?>{'source': 'tests'});

          return http.Response(
            jsonEncode(<String, Object?>{
              'success': true,
              'data': <String, Object?>{'success': true},
            }),
            202,
            headers: <String, String>{'content-type': 'application/json'},
          );
        });

        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        await sdk.registerFirebaseMessagingToken(
          'fcm_token_123',
          metadata: <String, Object?>{'source': 'tests'},
        );
      },
    );

    test(
      'registerFirebaseMessagingToken accepts an empty token to clear the uninstall token',
      () async {
        client = MockClient((request) async {
          if (request.url.path == '/api/sdk/v1/open') {
            return http.Response(
              _sdkEnvelope(<String, Object?>{
                'userId': 'user_1',
                'isNewUser': true,
                'isFirstLaunch': true,
                'requestVersion': 'v1',
                'acceptedAt': '2026-05-06T10:00:00.000Z',
              }),
              200,
              headers: const <String, String>{
                'content-type': 'application/json',
              },
            );
          }

          expect(request.method, 'POST');
          expect(request.url.path, '/api/sdk/v1/uninstall-tokens');

          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['appToken'], 'ax_test_token');
          expect(body['deviceId'], isNotEmpty);
          expect(body['deviceIdSource'], isNotEmpty);
          expect(body['platform'], 'android');
          expect(body['provider'], 'fcm');
          expect(body.containsKey('token'), isFalse);

          return http.Response(
            jsonEncode(<String, Object?>{
              'success': true,
              'data': <String, Object?>{'success': true},
            }),
            202,
            headers: <String, String>{'content-type': 'application/json'},
          );
        });

        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        await sdk.registerFirebaseMessagingToken('   ');
      },
    );

    test(
      'registerFirebaseMessagingToken rejects unsupported platforms',
      () async {
        contextCollector = CountingContextCollector(
          platform: AttriaxPlatformType.windows,
        );
        sdk = Attriax.test(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();

        await expectLater(
          () => sdk.registerFirebaseMessagingToken('fcm_token_123'),
          throwsA(isA<UnsupportedError>()),
        );
      },
    );

    test(
      'queues session heartbeats while the app stays foregrounded',
      () async {
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: const AttriaxConfig(
            appToken: 'ax_test_token',
            sessionHeartbeatInterval: Duration(milliseconds: 25),
            firstLaunchSessionHeartbeatInterval: Duration(milliseconds: 25),
          ),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        final session = _storedSessionSnapshot(prefs);
        expect(session, isNotNull);

        await Future<void>.delayed(const Duration(milliseconds: 90));
        await _flushRuntimeTransitions();

        final bodies = _queuedBodiesFromPrefs(prefs);
        expect(bodies, isNotEmpty);
        expect(bodies.every((body) => body['kind'] == 'heartbeat'), isTrue);
        expect(bodies.first['sessionId'], session!.id);
      },
    );

    test(
      'queues pause and resume lifecycle telemetry for the same session',
      () async {
        var now = DateTime.utc(2026, 5, 3, 12, 0);
        final clock = AttriaxMutableClock(now);
        connectivityPlatform = FakeConnectivityPlatform(
          currentResults: const <ConnectivityResult>[ConnectivityResult.none],
        );
        ConnectivityPlatform.instance = connectivityPlatform;
        connectivity = Connectivity();
        sdk = Attriax.test(
          config: AttriaxConfig(appToken: 'ax_test_token', clock: clock),
          client: client,
          deepLinkSource: deepLinkSource,
          connectivity: connectivity,
          contextCollector: contextCollector,
          prefs: prefs,
          enableDebugLogs: false,
        );

        await sdk.init();
        final session = _storedSessionSnapshot(prefs);
        expect(session, isNotNull);

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.paused,
        );
        await _flushRuntimeTransitions();

        now = now.add(const Duration(seconds: 3));
        clock.currentTime = now;
        TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await _flushRuntimeTransitions();

        final bodies = _queuedBodiesFromPrefs(prefs);
        expect(bodies.map((body) => body['kind']).toList(), <Object?>[
          'pause',
          'resume',
        ]);
        expect(bodies[0]['sessionId'], session!.id);
        expect(bodies[0]['sessionRelativeTimeMs'], 3000);
        expect(bodies[1]['sessionId'], session.id);
        expect(bodies[1]['sessionRelativeTimeMs'], 6000);
      },
    );
  });
}

AttriaxSessionSnapshot? _storedSessionSnapshot(SharedPreferences prefs) {
  final raw = prefs.getString(
    AttriaxPreferencesStore.sessionSnapshotStorageKey,
  );
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final decoded = jsonDecode(raw) as Map<String, Object?>;
  return AttriaxSessionSnapshot.fromJson(decoded);
}

List<Map<String, Object?>> _queuedEntriesFromPrefs(SharedPreferences prefs) {
  final queuedRaw = prefs.getString('attriax.queue.v1');
  expect(queuedRaw, isNotNull);

  final decoded = jsonDecode(queuedRaw!) as List<Object?>;
  return decoded.cast<Map<String, Object?>>().toList(growable: false);
}

List<Map<String, Object?>> _queuedBodiesFromPrefs(SharedPreferences prefs) =>
    _queuedEntriesFromPrefs(prefs)
        .where((entry) => entry['kind'] != 'open')
        .map((entry) => entry['body'] as Map<String, Object?>)
        .toList(growable: false);

Future<void> _flushRuntimeTransitions() => pumpEventQueue();

class FakeDeepLinkSource implements AttriaxDeepLinkSource {
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();
  int getInitialLinkCalls = 0;

  @override
  Future<Uri?> getInitialLink() async {
    getInitialLinkCalls += 1;
    return null;
  }

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  Future<void> dispose() => _controller.close();
}

class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({List<ConnectivityResult>? currentResults})
    : _currentResults =
          currentResults ?? const <ConnectivityResult>[ConnectivityResult.wifi];
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  List<ConnectivityResult> _currentResults;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _currentResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  Future<void> emit(List<ConnectivityResult> results) async {
    _currentResults = results;
    _controller.add(results);
  }

  Future<void> dispose() => _controller.close();
}

class CountingContextCollector extends AttriaxContextCollector {
  CountingContextCollector({this.platform = AttriaxPlatformType.android})
    : super(config: const AttriaxConfig(appToken: 'ax_test_token'));

  int collectContextSnapshotCalls = 0;
  int resolvePreferredDeviceIdCalls = 0;
  final List<String> collectedContextDeviceIds = <String>[];
  AttriaxResolvedDeviceId? resolvedDeviceId;
  final AttriaxPlatformType platform;

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async {
    resolvePreferredDeviceIdCalls += 1;
    return resolvedDeviceId ??
        AttriaxResolvedDeviceId(
          value: fallbackDeviceId,
          source: attriaxPersistentStorageDeviceIdSource,
          isFallback: true,
        );
  }

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
  }) async {
    collectContextSnapshotCalls += 1;
    collectedContextDeviceIds.add(deviceId);
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
      device: const AttriaxDeviceSnapshot(model: 'Test Device', osVersion: '1'),
    );
  }
}

class FakeCrashReportingPlatform extends AttriaxPlatform {
  FakeCrashReportingPlatform({
    AttriaxPendingCrashReport? pendingCrashReport,
    AttriaxInstallReferrerContext installReferrerContext =
        const AttriaxInstallReferrerContext(
          installReferrer: 'utm_source=attriax&utm_campaign=tests',
        ),
  }) : _pendingCrashReport = pendingCrashReport,
       _installReferrerContext = installReferrerContext;

  AttriaxPendingCrashReport? _pendingCrashReport;
  final AttriaxInstallReferrerContext _installReferrerContext;
  int consumePendingCrashReportCalls = 0;
  final List<bool> automaticCrashReportingValues = <bool>[];

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async =>
      _installReferrerContext;

  @override
  Future<void> setAutomaticCrashReportingEnabled({
    required bool enabled,
  }) async {
    automaticCrashReportingValues.add(enabled);
  }

  @override
  Future<AttriaxPendingCrashReport?> consumePendingCrashReport() async {
    consumePendingCrashReportCalls += 1;
    final report = _pendingCrashReport;
    _pendingCrashReport = null;
    return report;
  }
}

class DelayedInstallReferrerPlatform extends AttriaxPlatform {
  final Completer<AttriaxInstallReferrerContext> _completer =
      Completer<AttriaxInstallReferrerContext>();

  void complete(AttriaxInstallReferrerContext context) {
    if (!_completer.isCompleted) {
      _completer.complete(context);
    }
  }

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() =>
      _completer.future;
}

String _sdkEnvelope(Map<String, Object?> data) => jsonEncode(<String, Object?>{
  'success': true,
  'timestamp': '2026-05-06T10:00:00.000Z',
  'data': data,
});

generated_sdk.SdkV1BatchResponseEnvelopeDto _batchEnvelope() =>
    generated_sdk.SdkV1BatchResponseEnvelopeDto(
      (builder) => builder
        ..data.replace(
          generated_sdk.SdkV1BatchResponseDto(
            (builder) => builder
              ..acceptedAt = DateTime.utc(2026, 5, 6, 10, 0)
              ..duplicateCount = 0
              ..itemCount = 1
              ..processedCount = 1
              ..requestVersion = 'v1',
          ),
        )
        ..success = true
        ..timestamp = DateTime.utc(2026, 5, 6, 10, 0),
    );

Object? _serializeGenerated<T>(Serializer<T> serializer, T value) =>
    generated_sdk.standardSerializers.serializeWith(serializer, value);
