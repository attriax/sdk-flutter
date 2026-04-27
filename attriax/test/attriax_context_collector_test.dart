import 'package:attriax/attriax.dart';
import 'package:attriax/src/internal/attriax_context_collector.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttriaxContextCollector install referrer retry', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('retries once and returns the successful referrer payload', () async {
      final platform = FakeAttriaxPlatform(<AttriaxInstallReferrerContext>[
        const AttriaxInstallReferrerContext(
          metadata: <String, Object?>{'installReferrerStatus': 'service_unavailable'},
        ),
        const AttriaxInstallReferrerContext(
          installReferrer: 'utm_source=play_store',
          metadata: <String, Object?>{'installReferrerStatus': 'ok'},
        ),
      ]);

      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        installReferrerRetryDelay: Duration.zero,
      );

      final context = await collector.collectInstallReferrerContextForTest(
        platformType: AttriaxPlatformType.android,
      );

      expect(platform.installReferrerCalls, 2);
      expect(context.installReferrer, 'utm_source=play_store');
      expect(context.metadata['installReferrerStatus'], 'ok');
    });

    test('emits degraded metadata after both install referrer attempts fail', () async {
      final platform = FakeAttriaxPlatform(<AttriaxInstallReferrerContext>[
        const AttriaxInstallReferrerContext(
          metadata: <String, Object?>{'installReferrerStatus': 'service_unavailable'},
        ),
        const AttriaxInstallReferrerContext(
          metadata: <String, Object?>{'installReferrerStatus': 'timeout_flutter'},
        ),
      ]);

      final collector = AttriaxContextCollector(
        config: const AttriaxConfig(appToken: 'ax_test_token'),
        platform: platform,
        installReferrerRetryDelay: Duration.zero,
      );

      final context = await collector.collectInstallReferrerContextForTest(
        platformType: AttriaxPlatformType.android,
      );

      expect(platform.installReferrerCalls, 2);
      expect(context.installReferrer, isNull);
      expect(context.metadata['installReferrerStatus'], 'timeout_flutter');
      expect(context.metadata['installReferrerAttempts'], 2);
    });
  });

  test('overrides sdk metadata with the Flutter client runtime marker', () async {
    final collector = AttriaxContextCollector(
      config: const AttriaxConfig(
        appToken: 'ax_test_token',
        sdkMetadata: <String, Object?>{
          'clientRuntime': 'custom',
          'customField': 'kept',
        },
      ),
      platform: FakeAttriaxPlatform(const <AttriaxInstallReferrerContext>[]),
    );

    final context = await collector.collect(
      deviceId: 'device_test_1',
      isFirstLaunch: true,
    );

    expect(context.sdk.metadata['clientRuntime'], 'flutter');
    expect(context.sdk.metadata['customField'], 'kept');
  });
}

class FakeAttriaxPlatform extends AttriaxPlatform {
  FakeAttriaxPlatform(this._responses);

  final List<AttriaxInstallReferrerContext> _responses;
  int installReferrerCalls = 0;

  @override
  Future<AttriaxNativeContext> collectNativeContext() async =>
      const AttriaxNativeContext();

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async {
    final index = installReferrerCalls;
    installReferrerCalls += 1;

    if (index < _responses.length) {
      return _responses[index];
    }

    return const AttriaxInstallReferrerContext();
  }
}