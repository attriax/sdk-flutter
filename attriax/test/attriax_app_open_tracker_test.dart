import 'package:attriax_flutter/src/internal/attriax_api_models.dart';
import 'package:attriax_flutter/src/internal/attriax_app_open_tracker.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:attriax_flutter/src/internal/attriax_request_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxAppOpenTracker', () {
    late FakeRequestManager requestManager;
    late AttriaxAppOpenTracker tracker;
    late AttriaxContextSnapshot context;

    setUp(() async {
      requestManager = FakeRequestManager();
      tracker = AttriaxAppOpenTracker();
      context = const AttriaxContextSnapshot(
        platform: AttriaxPlatformType.android,
        deviceId: 'device_1',
        isFirstLaunch: true,
        sdk: AttriaxSdkSnapshot(
          apiVersion: attriaxSdkApiVersion,
          packageVersion: attriaxSdkPackageVersion,
        ),
        app: AttriaxAppSnapshot(
          version: '1.0.0',
          buildNumber: '1',
          packageName: 'com.attriax.test',
        ),
        device: AttriaxDeviceSnapshot(model: 'Pixel', osVersion: '14'),
      );
    });

    tearDown(() async {
      await tracker.dispose();
    });

    test('returns null immediately when no app-open was scheduled', () async {
      expect(await tracker.waitForResult(), isNull);
    });

    test(
      'schedules at most one request and reuses the successful result',
      () async {
        await tracker.schedule(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          context: context,
          rawPlatformInstallReferrer: null,
          deviceIdSource: 'android_ssaid',
          session: null,
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );
        await tracker.schedule(
          config: const AttriaxConfig(appToken: 'ax_test_token'),
          context: context,
          rawPlatformInstallReferrer: null,
          deviceIdSource: 'android_ssaid',
          session: null,
          requestManager: requestManager,
          logger: AttriaxLogger(enableDebugLogs: false),
        );

        expect(requestManager.enqueueCalls, 1);

        const result = AttriaxAppOpenResult(
          userId: 'user_1',
          isNewUser: true,
          isFirstLaunch: true,
        );
        requestManager.completeSuccess(
          const AttriaxOpenApiResponse(result: result),
        );

        expect(await tracker.waitForResult(), same(result));
        expect(tracker.lastResult, same(result));
        expect(await tracker.waitForResult(), same(result));
      },
    );

    test('propagates request manager errors', () async {
      await tracker.schedule(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        context: context,
        rawPlatformInstallReferrer: null,
        deviceIdSource: 'android_ssaid',
        session: null,
        requestManager: requestManager,
        logger: AttriaxLogger(enableDebugLogs: false),
      );

      requestManager.completeError(StateError('request failed'));

      await expectLater(tracker.waitForResult(), throwsA(isA<StateError>()));
    });
  });
}

class FakeRequestManager extends AttriaxRequestManager {
  int enqueueCalls = 0;
  void Function(AttriaxApiResponse response)? _onSuccess;
  void Function(Object error, StackTrace? stackTrace)? _onError;

  @override
  Future<void> enqueue(
    AttriaxApiRequest request, {
    void Function(AttriaxApiResponse response)? onSuccess,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool flushImmediately = true,
  }) async {
    enqueueCalls += 1;
    _onSuccess = onSuccess;
    _onError = onError;
  }

  void completeSuccess(AttriaxApiResponse response) {
    _onSuccess?.call(response);
  }

  void completeError(Object error, {StackTrace? stackTrace}) {
    _onError?.call(error, stackTrace);
  }
}
