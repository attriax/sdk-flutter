import 'dart:async';

import 'package:attriax_flutter/src/internal/attriax_tracking_authorization_manager.dart';
import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
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
