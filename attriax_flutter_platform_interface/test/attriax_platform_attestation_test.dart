import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(attriaxAttestationMethodChannelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  AttriaxPlatformAttestationProvider providerForPlatform(
    AttriaxPlatformType platform,
  ) => AttriaxPlatformAttestationProvider(
    currentPlatform: () => platform,
    channel: channel,
  );

  group('attriaxAttestationProviderSlugForPlatform', () {
    test('maps android to play_integrity', () {
      expect(
        attriaxAttestationProviderSlugForPlatform(AttriaxPlatformType.android),
        AttriaxAttestationProviderSlug.playIntegrity,
      );
    });

    test('maps ios and macos to app_attest', () {
      expect(
        attriaxAttestationProviderSlugForPlatform(AttriaxPlatformType.ios),
        AttriaxAttestationProviderSlug.appAttest,
      );
      expect(
        attriaxAttestationProviderSlugForPlatform(AttriaxPlatformType.macos),
        AttriaxAttestationProviderSlug.appAttest,
      );
    });

    test('returns null for platforms without native attestation', () {
      for (final platform in <AttriaxPlatformType>[
        AttriaxPlatformType.web,
        AttriaxPlatformType.windows,
        AttriaxPlatformType.linux,
        AttriaxPlatformType.unknown,
      ]) {
        expect(attriaxAttestationProviderSlugForPlatform(platform), isNull);
      }
    });
  });

  group('AttriaxPlatformAttestationProvider', () {
    test(
      'android forwards play_integrity + nonce and assembles the envelope',
      () async {
        MethodCall? seenCall;
        messenger.setMockMethodCallHandler(channel, (methodCall) async {
          seenCall = methodCall;
          return <String, Object?>{'token': 'integrity_token'};
        });

        final provider = providerForPlatform(AttriaxPlatformType.android);
        final envelope = await provider.attest('server_nonce');

        expect(seenCall?.method, attriaxAcquireAttestationTokenMethod);
        expect(seenCall?.arguments, <String, Object?>{
          'nonce': 'server_nonce',
          'provider': 'play_integrity',
        });
        expect(envelope, isNotNull);
        expect(envelope!.provider, 'play_integrity');
        expect(envelope.token, 'integrity_token');
        expect(envelope.nonce, 'server_nonce');
        expect(envelope.keyId, isNull);
      },
    );

    test('ios forwards app_attest and carries the native keyId', () async {
      MethodCall? seenCall;
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        seenCall = methodCall;
        return <String, Object?>{
          'token': 'app_attest_token',
          'keyId': 'key_abc',
        };
      });

      final provider = providerForPlatform(AttriaxPlatformType.ios);
      final envelope = await provider.attest('server_nonce');

      expect((seenCall?.arguments as Map)['provider'], 'app_attest');
      expect(envelope!.provider, 'app_attest');
      expect(envelope.token, 'app_attest_token');
      expect(envelope.nonce, 'server_nonce');
      expect(envelope.keyId, 'key_abc');
    });

    test('returns null when the native result carries no token', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (methodCall) async => <String, Object?>{'provider': 'play_integrity'},
      );

      final provider = providerForPlatform(AttriaxPlatformType.android);
      expect(await provider.attest('server_nonce'), isNull);
    });

    test(
      'returns null (degrades) when the native handler is missing',
      () async {
        // No mock handler registered → MissingPluginException.
        final provider = providerForPlatform(AttriaxPlatformType.android);
        expect(await provider.attest('server_nonce'), isNull);
      },
    );

    test('returns null when the native handler throws', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (methodCall) async =>
            throw PlatformException(code: 'ATTESTATION_FAILED'),
      );

      final provider = providerForPlatform(AttriaxPlatformType.android);
      expect(await provider.attest('server_nonce'), isNull);
    });

    test(
      'returns null on unsupported platforms without hitting the channel',
      () async {
        var handlerCalls = 0;
        messenger.setMockMethodCallHandler(channel, (methodCall) async {
          handlerCalls += 1;
          return <String, Object?>{'token': 'unexpected'};
        });

        final provider = providerForPlatform(AttriaxPlatformType.web);
        expect(await provider.attest('server_nonce'), isNull);
        expect(handlerCalls, 0);
      },
    );

    test(
      'returns null for a blank nonce without hitting the channel',
      () async {
        var handlerCalls = 0;
        messenger.setMockMethodCallHandler(channel, (methodCall) async {
          handlerCalls += 1;
          return <String, Object?>{'token': 'unexpected'};
        });

        final provider = providerForPlatform(AttriaxPlatformType.android);
        expect(await provider.attest('   '), isNull);
        expect(handlerCalls, 0);
      },
    );
  });
}
