import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(attriaxAsaMethodChannelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  AttriaxAdServicesTokenProvider providerForPlatform(
    AttriaxPlatformType platform,
  ) => AttriaxAdServicesTokenProvider(
    currentPlatform: () => platform,
    channel: channel,
  );

  group('AttriaxAdServicesTokenProvider', () {
    test('ios invokes acquireAdServicesToken and returns the token', () async {
      MethodCall? seenCall;
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        seenCall = methodCall;
        return 'asa_token';
      });

      final provider = providerForPlatform(AttriaxPlatformType.ios);
      final token = await provider.acquireToken();

      expect(seenCall?.method, attriaxAcquireAdServicesTokenMethod);
      expect(token, 'asa_token');
    });

    test('accepts a map result carrying a token field', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (methodCall) async => <String, Object?>{'token': ' asa_token '},
      );

      final provider = providerForPlatform(AttriaxPlatformType.ios);
      expect(await provider.acquireToken(), 'asa_token');
    });

    test(
      'returns null on non-iOS platforms without hitting the channel',
      () async {
        var handlerCalls = 0;
        messenger.setMockMethodCallHandler(channel, (methodCall) async {
          handlerCalls += 1;
          return 'unexpected';
        });

        for (final platform in <AttriaxPlatformType>[
          AttriaxPlatformType.android,
          AttriaxPlatformType.macos,
          AttriaxPlatformType.web,
          AttriaxPlatformType.windows,
          AttriaxPlatformType.linux,
          AttriaxPlatformType.unknown,
        ]) {
          final provider = providerForPlatform(platform);
          expect(await provider.acquireToken(), isNull);
        }
        expect(handlerCalls, 0);
      },
    );

    test(
      'returns null (degrades) when the native handler is missing',
      () async {
        // No mock handler registered → MissingPluginException.
        final provider = providerForPlatform(AttriaxPlatformType.ios);
        expect(await provider.acquireToken(), isNull);
      },
    );

    test('returns null when the native handler returns null (stub)', () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async => null);

      final provider = providerForPlatform(AttriaxPlatformType.ios);
      expect(await provider.acquireToken(), isNull);
    });

    test(
      'returns null when the native handler returns a blank token',
      () async {
        messenger.setMockMethodCallHandler(
          channel,
          (methodCall) async => '   ',
        );

        final provider = providerForPlatform(AttriaxPlatformType.ios);
        expect(await provider.acquireToken(), isNull);
      },
    );

    test('returns null when the native handler throws', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (methodCall) async => throw PlatformException(code: 'ASA_FAILED'),
      );

      final provider = providerForPlatform(AttriaxPlatformType.ios);
      expect(await provider.acquireToken(), isNull);
    });
  });
}
