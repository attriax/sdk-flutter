import 'dart:async';
import 'dart:convert';

import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_app_open_monitor.dart';
import 'package:attriax_flutter/src/internal/attriax_context_collector.dart';
import 'package:attriax_flutter/src/internal/attriax_generated_transport.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_preferences_store.dart';
import 'package:attriax_flutter/src/internal/attriax_queue.dart';
import 'package:attriax_flutter/src/internal/attriax_request_dispatcher.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AttriaxPlatform originalPlatform;
  late ConnectivityPlatform originalConnectivityPlatform;

  setUp(() async {
    originalPlatform = AttriaxPlatform.instance;
    originalConnectivityPlatform = ConnectivityPlatform.instance;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    AttriaxPlatform.instance = originalPlatform;
    ConnectivityPlatform.instance = originalConnectivityPlatform;
  });

  testWidgets('imports pending native crash reports during startup', (
    tester,
  ) async {
    final crashRequestCompleter = Completer<_RecordedRequest>();
    final platform = _FakeCrashReportingPlatform(
      pendingCrashReport: AttriaxPendingCrashReport(
        source: 'android_uncaught_exception',
        isFatal: true,
        exceptionType: 'java.lang.IllegalStateException',
        message: 'boom',
        stackTrace: 'native stack',
        occurredAt: DateTime.utc(2026, 5, 4, 10),
        metadata: const <String, Object?>{'threadName': 'main'},
      ),
    );
    AttriaxPlatform.instance = platform;

    final client = _FakeHttpClient((request) async {
      final recorded = _recordRequest(request as http.Request);
      switch (request.url.path) {
        case '/api/sdk/v1/open':
          return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
        case '/api/sdk/v1/crashes':
          if (!crashRequestCompleter.isCompleted) {
            crashRequestCompleter.complete(recorded);
          }
          return _jsonResponse(202, <String, Object?>{
            'data': <String, Object?>{'success': true},
          });
        default:
          return _jsonResponse(404, <String, Object?>{
            'success': false,
            'message': 'Unhandled test path ${request.url.path}',
          });
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final connectivityPlatform = _FakeConnectivityPlatform();
    ConnectivityPlatform.instance = connectivityPlatform;
    final attriax = _buildSdk(
      client: client,
      prefs: prefs,
      config: const AttriaxConfig(
        appToken: 'ax_test_token',
        apiBaseUrl: 'https://api.attriax.test',
        requestTimeout: Duration(seconds: 5),
        automaticCrashReportingEnabled: true,
        sessionTrackingEnabled: false,
      ),
    );

    addTearDown(() async {
      await attriax.reset();
      client.close();
      await connectivityPlatform.dispose();
    });

    await attriax.init();

    final crashRequest = await crashRequestCompleter.future.timeout(
      const Duration(seconds: 10),
    );
    expect(crashRequest.body['source'], 'android_uncaught_exception');
    expect(crashRequest.body['message'], 'boom');
    expect(
      crashRequest.body['exceptionType'],
      'java.lang.IllegalStateException',
    );
    expect(platform.consumePendingCrashReportCalls, 1);

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
  });

  testWidgets('holds queued work until startup install referrer finishes', (
    tester,
  ) async {
    final platform = _DelayedInstallReferrerPlatform();
    AttriaxPlatform.instance = platform;

    final requestPaths = <String>[];
    final batchRequests = <_RecordedRequest>[];
    final client = _FakeHttpClient((request) async {
      final recorded = _recordRequest(request as http.Request);
      requestPaths.add(request.url.path);
      switch (request.url.path) {
        case '/api/sdk/v1/open':
          return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
        case '/api/sdk/v1/batch':
          batchRequests.add(recorded);
          return _jsonResponse(202, _serializeGenerated(_batchEnvelope()));
        default:
          return _jsonResponse(404, <String, Object?>{
            'success': false,
            'message': 'Unhandled test path ${request.url.path}',
          });
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final connectivityPlatform = _FakeConnectivityPlatform();
    ConnectivityPlatform.instance = connectivityPlatform;
    final attriax = _buildSdk(
      client: client,
      prefs: prefs,
      config: const AttriaxConfig(
        appToken: 'ax_test_token',
        apiBaseUrl: 'https://api.attriax.test',
        requestTimeout: Duration(seconds: 5),
        automaticCrashReportingEnabled: false,
        sessionTrackingEnabled: false,
      ),
    );

    addTearDown(() async {
      platform.complete(const AttriaxInstallReferrerContext());
      await attriax.reset();
      client.close();
      await connectivityPlatform.dispose();
    });

    await attriax.init().timeout(const Duration(milliseconds: 200));
    await attriax.tracking.recordEvent(
      'purchase',
      eventData: const <String, Object?>{'value': 42},
    );
    await pumpEventQueue();

    expect(requestPaths, isEmpty);

    platform.complete(
      const AttriaxInstallReferrerContext(
        installReferrer: 'utm_source=attriax&utm_campaign=delayed',
      ),
    );
    await pumpEventQueue();

    expect(requestPaths, <String>['/api/sdk/v1/open', '/api/sdk/v1/batch']);
    expect(batchRequests, hasLength(1));

    final items = batchRequests.single.body['items']! as List<Object?>;
    expect(items, hasLength(1));
    final item = items.single! as Map<String, Object?>;
    expect(item['kind'], 'event');
  });

  testWidgets('persists retry-after windows for queued event retries', (
    tester,
  ) async {
    final batchRequests = <_RecordedRequest>[];
    final client = _FakeHttpClient((request) async {
      final recorded = _recordRequest(request as http.Request);
      switch (request.url.path) {
        case '/api/sdk/v1/open':
          return _jsonResponse(200, _serializeGenerated(_openEnvelope()));
        case '/api/sdk/v1/batch':
          batchRequests.add(recorded);
          return _jsonResponse(
            429,
            <String, Object?>{'message': 'retry later'},
            extraHeaders: const <String, String>{'retry-after': '60'},
          );
        default:
          return _jsonResponse(404, <String, Object?>{
            'success': false,
            'message': 'Unhandled test path ${request.url.path}',
          });
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final preferencesStore = AttriaxPreferencesStore(prefsOverride: prefs);
    final queueManager = AttriaxQueueManager(
      preferencesStore: preferencesStore,
      maxQueueSize: 10,
    );
    final connectivityPlatform = _FakeConnectivityPlatform();
    ConnectivityPlatform.instance = connectivityPlatform;
    final transport = AttriaxGeneratedTransport(
      apiBaseUrl: 'https://api.attriax.test',
      requestTimeout: const Duration(seconds: 5),
      httpClient: client,
    );
    final dispatcher = AttriaxRequestDispatcher(
      transport: transport,
      connectivity: Connectivity(),
      appOpenMonitor: _FakeAppOpenMonitor(),
      queueManager: queueManager,
      logger: AttriaxLogger(enableDebugLogs: false),
    );
    final queuedRequest = AttriaxQueuedRequest(
      id: 'req_1',
      request: attriaxBuildTrackEventRequest(
        appToken: 'ax_test_token',
        deviceId: 'device_test_android',
        deviceIdSource: 'android_ssaid',
        eventName: 'purchase',
        eventData: const <String, Object?>{'value': 42},
      ),
      createdAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
    );

    addTearDown(() async {
      client.close();
      await connectivityPlatform.dispose();
    });

    await queueManager.writeAll(<AttriaxQueuedRequest>[queuedRequest]);
    await dispatcher.flush();

    expect(batchRequests, hasLength(1));

    final queued = await _waitForQueuedEntries(prefs, expectedLength: 1);
    expect(queued, hasLength(1));
    expect(queued.single['kind'], 'trackEvent');

    final nextRetryAt = DateTime.parse(
      queued.single['nextRetryAt']! as String,
    ).toUtc();
    expect(
      nextRetryAt.isAfter(
        DateTime.now().toUtc().add(const Duration(seconds: 59)),
      ),
      isTrue,
    );
  });
}

Attriax _buildSdk({
  required http.Client client,
  required SharedPreferences prefs,
  required AttriaxConfig config,
}) => Attriax.test(
  config: config,
  client: client,
  deepLinkSource: const _NoopDeepLinkSource(),
  connectivity: Connectivity(),
  contextCollector: _StaticContextCollector(config: config),
  prefs: prefs,
  enableDebugLogs: false,
);

List<Map<String, Object?>> _queuedEntriesFromPrefs(SharedPreferences prefs) {
  final queuedRaw = prefs.getString(AttriaxPreferencesStore.queueStorageKey);
  if (queuedRaw == null) {
    return const <Map<String, Object?>>[];
  }

  final decoded = jsonDecode(queuedRaw) as List<Object?>;
  return decoded.cast<Map<String, Object?>>().toList(growable: false);
}

Future<List<Map<String, Object?>>> _waitForQueuedEntries(
  SharedPreferences prefs, {
  required int expectedLength,
}) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    final queued = _queuedEntriesFromPrefs(prefs);
    if (queued.length == expectedLength) {
      return queued;
    }
    await Future<void>.delayed(Duration.zero);
  }

  return _queuedEntriesFromPrefs(prefs);
}

_RecordedRequest _recordRequest(http.Request request) {
  final decodedBody = (jsonDecode(utf8.decode(request.bodyBytes)) as Map)
      .cast<String, Object?>();
  return _RecordedRequest(path: request.url.path, body: decodedBody);
}

sdk.SdkV1OpenResponseEnvelopeDto _openEnvelope() =>
    sdk.SdkV1OpenResponseEnvelopeDto(
      data: sdk.SdkV1OpenResponseDto(
        acceptedAt: DateTime.utc(2026, 1, 1, 0, 0, 0),
        installState: sdk.SdkInstallState.existing,
        isFirstLaunch: true,
        isNewUser: true,
        requestVersion: 'req_v1',
        userId: 'user_1',
      ),
      success: true,
      timestamp: DateTime.utc(2026, 1, 1, 0, 0, 0),
    );

sdk.SdkV1BatchResponseEnvelopeDto _batchEnvelope() =>
    sdk.SdkV1BatchResponseEnvelopeDto(
      data: sdk.SdkV1BatchResponseDto(
        acceptedAt: DateTime.utc(2026, 1, 1, 0, 0, 0),
        duplicateCount: 0,
        itemCount: 1,
        processedCount: 1,
        requestVersion: 'req_v1',
      ),
      success: true,
      timestamp: DateTime.utc(2026, 1, 1, 0, 0, 0),
    );

Object? _serializeGenerated(Object value) {
  final dynamic serializable = value;
  return serializable.toJson();
}

http.StreamedResponse _jsonResponse(
  int statusCode,
  Object? body, {
  Map<String, String> extraHeaders = const <String, String>{},
}) => http.StreamedResponse(
  Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
  statusCode,
  headers: <String, String>{
    'content-type': 'application/json',
    ...extraHeaders,
  },
);

class _RecordedRequest {
  const _RecordedRequest({required this.path, required this.body});

  final String path;
  final Map<String, Object?> body;
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handler(request);
}

class _NoopDeepLinkSource implements AttriaxDeepLinkSource {
  const _NoopDeepLinkSource();

  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  Stream<Uri> get uriLinkStream => const Stream<Uri>.empty();
}

class _FakeConnectivityPlatform extends ConnectivityPlatform {
  _FakeConnectivityPlatform({List<ConnectivityResult>? currentResults})
    : _currentResults =
          currentResults ?? const <ConnectivityResult>[ConnectivityResult.wifi];

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  final List<ConnectivityResult> _currentResults;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _currentResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  Future<void> dispose() => _controller.close();
}

class _StaticContextCollector extends AttriaxContextCollector {
  _StaticContextCollector({required super.config})
    : super(platformType: AttriaxPlatformType.android);

  @override
  Future<AttriaxContextSnapshot> collectContextSnapshot({
    required String deviceId,
    required bool isFirstLaunch,
  }) async => AttriaxContextSnapshot(
    platform: AttriaxPlatformType.android,
    deviceId: deviceId,
    isFirstLaunch: isFirstLaunch,
    sdk: const AttriaxSdkSnapshot(
      apiVersion: attriaxSdkApiVersion,
      packageVersion: attriaxSdkPackageVersion,
    ),
    app: const AttriaxAppSnapshot(
      version: '1.0.0',
      buildNumber: '1',
      packageName: 'com.attriax.example',
    ),
    device: const AttriaxDeviceSnapshot(
      model: 'Pixel Test Device',
      osVersion: '14',
      language: 'en-US',
      timezone: 'UTC',
    ),
  );

  @override
  Future<AttriaxResolvedDeviceId> resolvePreferredDeviceId({
    required String fallbackDeviceId,
  }) async => const AttriaxResolvedDeviceId(
    value: 'device_test_android',
    source: 'android_ssaid',
  );
}

class _FakeCrashReportingPlatform extends AttriaxPlatform {
  _FakeCrashReportingPlatform({this.pendingCrashReport});

  AttriaxPendingCrashReport? pendingCrashReport;
  int consumePendingCrashReportCalls = 0;

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async => const AttriaxNativeContext();

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async =>
      const AttriaxInstallReferrerContext(
        installReferrer: 'utm_source=attriax&utm_campaign=tests',
      );

  @override
  Future<AttriaxPendingCrashReport?> consumePendingCrashReport() async {
    consumePendingCrashReportCalls += 1;
    final report = pendingCrashReport;
    pendingCrashReport = null;
    return report;
  }
}

class _DelayedInstallReferrerPlatform extends AttriaxPlatform {
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

class _FakeAppOpenMonitor implements AttriaxAppOpenMonitor {
  @override
  bool get hasSuccessfulResult => true;

  @override
  bool get shouldGateRequestsOnSuccessfulAppOpen => true;

  @override
  Future<AttriaxAppOpenResult?> waitForTrackedResult() async => null;
}
