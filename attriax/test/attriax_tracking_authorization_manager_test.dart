import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_tracking_authorization_manager.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'getTrackingAuthorizationStatus reads the real platform status even when advertising IDs are disabled',
    () async {
      final platform = FakeAttriaxPlatform()
        ..trackingAuthorizationStatus =
            AttriaxTrackingAuthorizationStatus.authorized;
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          collectAdvertisingId: false,
        ),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      final status = await manager.getTrackingAuthorizationStatus();

      expect(status, AttriaxTrackingAuthorizationStatus.authorized);
      expect(platform.getTrackingAuthorizationStatusCalls, 1);
      expect(
        await manager.waitForTrackingAuthorizationIfNeeded(),
        AttriaxTrackingAuthorizationStatus.disabled,
      );
    },
  );

  test(
    'requestTrackingAuthorization forwards the real request even when advertising IDs are disabled',
    () async {
      final platform = FakeAttriaxPlatform()
        ..requestTrackingAuthorizationStatus =
            AttriaxTrackingAuthorizationStatus.authorized;
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          collectAdvertisingId: false,
        ),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      final status = await manager.requestTrackingAuthorization();

      expect(status, AttriaxTrackingAuthorizationStatus.authorized);
      expect(platform.requestTrackingAuthorizationCalls, 1);
      expect(platform.requestTrackingAuthorizationTimeouts, <Duration?>[null]);
    },
  );

  test(
    'requestTrackingAuthorization bypasses resolved cache and recaches the latest result',
    () async {
      final platform = FakeAttriaxPlatform()
        ..requestTrackingAuthorizationStatus =
            AttriaxTrackingAuthorizationStatus.authorized;
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      expect(
        await manager.requestTrackingAuthorization(),
        AttriaxTrackingAuthorizationStatus.authorized,
      );

      platform.requestTrackingAuthorizationStatus =
          AttriaxTrackingAuthorizationStatus.denied;

      expect(
        await manager.requestTrackingAuthorization(),
        AttriaxTrackingAuthorizationStatus.denied,
      );
      expect(platform.requestTrackingAuthorizationCalls, 2);
      expect(
        await manager.waitForTrackingAuthorizationIfNeeded(),
        AttriaxTrackingAuthorizationStatus.denied,
      );
      expect(platform.getTrackingAuthorizationStatusCalls, 0);
    },
  );

  test(
    'requestTrackingAuthorizationOnInit requests tracking authorization once before startup collection',
    () async {
      final platform = FakeAttriaxPlatform();
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          requestTrackingAuthorizationOnInit: true,
        ),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      expect(
        await manager.waitForTrackingAuthorizationIfNeeded(),
        AttriaxTrackingAuthorizationStatus.authorized,
      );
      expect(
        await manager.waitForTrackingAuthorizationIfNeeded(),
        AttriaxTrackingAuthorizationStatus.authorized,
      );

      expect(platform.requestTrackingAuthorizationCalls, 1);
      expect(platform.requestTrackingAuthorizationTimeouts, <Duration?>[null]);
      expect(platform.getTrackingAuthorizationStatusCalls, 0);
    },
  );

  test(
    'startup status polling avoids prompting and reuses the cached result',
    () async {
      final platform = FakeAttriaxPlatform()
        ..trackingAuthorizationStatusResponses =
            <AttriaxTrackingAuthorizationStatus>[
              AttriaxTrackingAuthorizationStatus.authorized,
            ];
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      expect(
        await manager.waitForTrackingAuthorizationIfNeeded(),
        AttriaxTrackingAuthorizationStatus.authorized,
      );
      expect(
        await manager.waitForTrackingAuthorizationIfNeeded(),
        AttriaxTrackingAuthorizationStatus.authorized,
      );

      expect(platform.getTrackingAuthorizationStatusCalls, 1);
      expect(platform.requestTrackingAuthorizationCalls, 0);
    },
  );

  testWidgets(
    'startup polling joins an explicit tracking authorization request',
    (tester) async {
      final requestCompleter = Completer<AttriaxTrackingAuthorizationStatus>();
      final platform = FakeAttriaxPlatform()
        ..trackingAuthorizationStatusResponses =
            <AttriaxTrackingAuthorizationStatus>[
              AttriaxTrackingAuthorizationStatus.notDetermined,
            ]
        ..requestTrackingAuthorizationCompleter = requestCompleter;
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(
          appToken: 'ax_test_token',
          trackingAuthorizationStatusTimeout: Duration(seconds: 5),
        ),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      final startupWait = manager.waitForTrackingAuthorizationIfNeeded();
      await tester.pump();

      expect(platform.getTrackingAuthorizationStatusCalls, 1);
      expect(platform.requestTrackingAuthorizationCalls, 0);

      final manualRequest = manager.requestTrackingAuthorization();
      await tester.pump();

      expect(platform.requestTrackingAuthorizationCalls, 1);
      expect(platform.requestTrackingAuthorizationTimeouts, <Duration?>[null]);

      requestCompleter.complete(AttriaxTrackingAuthorizationStatus.authorized);
      await tester.pump();

      platform.requestTrackingAuthorizationCompleter = null;

      expect(
        await manualRequest,
        AttriaxTrackingAuthorizationStatus.authorized,
      );
      expect(await startupWait, AttriaxTrackingAuthorizationStatus.authorized);

      platform.requestTrackingAuthorizationStatus =
          AttriaxTrackingAuthorizationStatus.denied;

      expect(
        await manager.requestTrackingAuthorization(),
        AttriaxTrackingAuthorizationStatus.denied,
      );
      expect(platform.getTrackingAuthorizationStatusCalls, 1);
      expect(platform.requestTrackingAuthorizationCalls, 2);
    },
  );

  testWidgets(
    'requestTrackingAuthorization waits for a resolved iOS status after a premature notDetermined callback',
    (tester) async {
      final platform = FakeAttriaxPlatform()
        ..requestTrackingAuthorizationStatus =
            AttriaxTrackingAuthorizationStatus.notDetermined
        ..trackingAuthorizationStatusResponses =
            <AttriaxTrackingAuthorizationStatus>[
              AttriaxTrackingAuthorizationStatus.notDetermined,
              AttriaxTrackingAuthorizationStatus.authorized,
            ];
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      final request = manager.requestTrackingAuthorization();
      await tester.pump();

      expect(platform.requestTrackingAuthorizationCalls, 1);
      expect(platform.getTrackingAuthorizationStatusCalls, 1);

      await tester.pump(const Duration(milliseconds: 250));

      expect(await request, AttriaxTrackingAuthorizationStatus.authorized);
      expect(platform.getTrackingAuthorizationStatusCalls, 2);
    },
  );

  testWidgets(
    'requestTrackingAuthorization times out when iOS status never resolves after a premature notDetermined callback',
    (tester) async {
      final platform = FakeAttriaxPlatform()
        ..requestTrackingAuthorizationStatus =
            AttriaxTrackingAuthorizationStatus.notDetermined
        ..trackingAuthorizationStatus =
            AttriaxTrackingAuthorizationStatus.notDetermined;
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      final request = manager.requestTrackingAuthorization(
        timeout: const Duration(milliseconds: 300),
      );
      await tester.pump();

      expect(platform.requestTrackingAuthorizationCalls, 1);
      expect(platform.getTrackingAuthorizationStatusCalls, 1);

      await tester.pump(const Duration(milliseconds: 301));

      expect(await request, AttriaxTrackingAuthorizationStatus.timedOut);
      expect(platform.getTrackingAuthorizationStatusCalls, 2);
    },
  );

  testWidgets(
    'requestTrackingAuthorization resolves from status polling when the iOS request callback stays pending',
    (tester) async {
      final requestCompleter = Completer<AttriaxTrackingAuthorizationStatus>();
      final platform = FakeAttriaxPlatform()
        ..requestTrackingAuthorizationCompleter = requestCompleter
        ..trackingAuthorizationStatusResponses =
            <AttriaxTrackingAuthorizationStatus>[
              AttriaxTrackingAuthorizationStatus.notDetermined,
              AttriaxTrackingAuthorizationStatus.authorized,
            ];
      final manager = AttriaxTrackingAuthorizationManager(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        platformType: AttriaxPlatformType.ios,
      );

      final request = manager.requestTrackingAuthorization();

      await tester.pump(const Duration(milliseconds: 250));

      expect(platform.requestTrackingAuthorizationCalls, 1);
      expect(platform.getTrackingAuthorizationStatusCalls, 1);

      await tester.pump(const Duration(milliseconds: 250));

      expect(await request, AttriaxTrackingAuthorizationStatus.authorized);
      expect(platform.getTrackingAuthorizationStatusCalls, 2);
    },
  );
}

class FakeAttriaxPlatform extends AttriaxPlatform {
  int requestTrackingAuthorizationCalls = 0;
  int getTrackingAuthorizationStatusCalls = 0;
  final List<Duration?> requestTrackingAuthorizationTimeouts = <Duration?>[];
  List<AttriaxTrackingAuthorizationStatus>
  trackingAuthorizationStatusResponses = <AttriaxTrackingAuthorizationStatus>[];
  AttriaxTrackingAuthorizationStatus trackingAuthorizationStatus =
      AttriaxTrackingAuthorizationStatus.notDetermined;
  AttriaxTrackingAuthorizationStatus requestTrackingAuthorizationStatus =
      AttriaxTrackingAuthorizationStatus.authorized;
  Completer<AttriaxTrackingAuthorizationStatus>?
  requestTrackingAuthorizationCompleter;

  @override
  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async {
    getTrackingAuthorizationStatusCalls += 1;

    if (trackingAuthorizationStatusResponses.isNotEmpty) {
      return trackingAuthorizationStatusResponses.removeAt(0);
    }

    return trackingAuthorizationStatus;
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    requestTrackingAuthorizationCalls += 1;
    requestTrackingAuthorizationTimeouts.add(timeout);

    final completer = requestTrackingAuthorizationCompleter;
    if (completer != null) {
      return completer.future;
    }

    return requestTrackingAuthorizationStatus;
  }
}
