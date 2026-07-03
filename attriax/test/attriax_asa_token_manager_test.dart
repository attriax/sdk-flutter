import 'package:attriax_flutter/src/internal/attriax_asa_token_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AttriaxLogger quietLogger() => AttriaxLogger(enableDebugLogs: false);

  AttriaxAsaTokenManager buildManager({
    required AttriaxPlatformType platformType,
    required Future<String?> Function() acquireToken,
    required void Function({required String projectToken, required String token})
    onSend,
    Future<void> Function()? sendBehavior,
  }) => AttriaxAsaTokenManager(
    config: const AttriaxConfig(projectToken: 'ax_test_token'),
    platformType: platformType,
    acquireToken: acquireToken,
    sendToken: ({required projectToken, required token}) async {
      onSend(projectToken: projectToken, token: token);
      if (sendBehavior != null) {
        await sendBehavior();
      }
    },
    logger: quietLogger(),
  );

  group('AttriaxAsaTokenManager', () {
    test('is unsupported and never acquires on non-iOS platforms', () async {
      var acquireCalls = 0;
      var sendCalls = 0;
      final manager = buildManager(
        platformType: AttriaxPlatformType.android,
        acquireToken: () async {
          acquireCalls += 1;
          return 'asa_token';
        },
        onSend: ({required projectToken, required token}) => sendCalls += 1,
      );

      expect(manager.isSupported, isFalse);
      await manager.captureAndReportIfNeeded();
      expect(acquireCalls, 0);
      expect(sendCalls, 0);
    });

    test('iOS + token available → POSTs projectToken + token', () async {
      String? sentProjectToken;
      String? sentToken;
      final manager = buildManager(
        platformType: AttriaxPlatformType.ios,
        acquireToken: () async => '  asa_token  ',
        onSend: ({required projectToken, required token}) {
          sentProjectToken = projectToken;
          sentToken = token;
        },
      );

      expect(manager.isSupported, isTrue);
      await manager.captureAndReportIfNeeded();
      expect(sentProjectToken, 'ax_test_token');
      // Whitespace is trimmed before sending.
      expect(sentToken, 'asa_token');
    });

    test('iOS + null token (stub native) → sends nothing', () async {
      var sendCalls = 0;
      final manager = buildManager(
        platformType: AttriaxPlatformType.ios,
        acquireToken: () async => null,
        onSend: ({required projectToken, required token}) => sendCalls += 1,
      );

      await manager.captureAndReportIfNeeded();
      expect(sendCalls, 0);
    });

    test('iOS + blank token → sends nothing', () async {
      var sendCalls = 0;
      final manager = buildManager(
        platformType: AttriaxPlatformType.ios,
        acquireToken: () async => '   ',
        onSend: ({required projectToken, required token}) => sendCalls += 1,
      );

      await manager.captureAndReportIfNeeded();
      expect(sendCalls, 0);
    });

    test('acquisition failure is swallowed (never throws)', () async {
      final manager = buildManager(
        platformType: AttriaxPlatformType.ios,
        acquireToken: () async => throw StateError('native boom'),
        onSend: ({required projectToken, required token}) {},
      );

      await expectLater(manager.captureAndReportIfNeeded(), completes);
    });

    test('send failure is swallowed (never throws)', () async {
      final manager = buildManager(
        platformType: AttriaxPlatformType.ios,
        acquireToken: () async => 'asa_token',
        onSend: ({required projectToken, required token}) {},
        sendBehavior: () async => throw StateError('network down'),
      );

      await expectLater(manager.captureAndReportIfNeeded(), completes);
    });

    test('runs at most once per instance', () async {
      var acquireCalls = 0;
      final manager = buildManager(
        platformType: AttriaxPlatformType.ios,
        acquireToken: () async {
          acquireCalls += 1;
          return 'asa_token';
        },
        onSend: ({required projectToken, required token}) {},
      );

      await manager.captureAndReportIfNeeded();
      await manager.captureAndReportIfNeeded();
      expect(acquireCalls, 1);
    });
  });
}
