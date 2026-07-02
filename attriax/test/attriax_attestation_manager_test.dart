import 'package:attriax_flutter/src/internal/attriax_attestation_manager.dart';
import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AttriaxLogger quietLogger() => AttriaxLogger(enableDebugLogs: false);

  group('AttriaxAttestationManager', () {
    test('is disabled by default and never fetches a challenge', () async {
      var challengeCalls = 0;
      final manager = AttriaxAttestationManager(
        config: const AttriaxConfig(projectToken: 'ax_test_token'),
        fetchChallenge: () async {
          challengeCalls += 1;
          return const AttriaxAttestationChallenge(nonce: 'nonce_1');
        },
        logger: quietLogger(),
      );

      expect(manager.isEnabled, isFalse);
      expect(await manager.resolveEnvelope(), isNull);
      expect(challengeCalls, 0);
    });

    test(
      'enabled + provider returns a token → fetches challenge and assembles the '
      'envelope with the provider slug and nonce',
      () async {
        var challengeCalls = 0;
        final manager = AttriaxAttestationManager(
          config: AttriaxConfig(
            projectToken: 'ax_test_token',
            attestationEnabled: true,
            attestationProvider: _StubAttestationProvider(
              (nonce) => AttriaxAttestationEnvelope(
                provider: AttriaxAttestationProviderSlug.playIntegrity,
                token: 'integrity_token',
                nonce: nonce,
              ),
            ),
          ),
          fetchChallenge: () async {
            challengeCalls += 1;
            return const AttriaxAttestationChallenge(
              nonce: 'server_nonce',
              expiresInSeconds: 120,
            );
          },
          logger: quietLogger(),
        );

        final envelope = await manager.resolveEnvelope();

        expect(challengeCalls, 1);
        expect(envelope, <String, Object?>{
          'provider': 'play_integrity',
          'token': 'integrity_token',
          'nonce': 'server_nonce',
        });
      },
    );

    test(
      'enabled + provider returns null → resolves to null (no envelope)',
      () async {
        final manager = AttriaxAttestationManager(
          config: AttriaxConfig(
            projectToken: 'ax_test_token',
            attestationEnabled: true,
            attestationProvider: _StubAttestationProvider((_) => null),
          ),
          fetchChallenge: () async =>
              const AttriaxAttestationChallenge(nonce: 'server_nonce'),
          logger: quietLogger(),
        );

        expect(await manager.resolveEnvelope(), isNull);
      },
    );

    test(
      'enabled + challenge fetch returns null → resolves to null and never '
      'calls the provider',
      () async {
        var providerCalls = 0;
        final manager = AttriaxAttestationManager(
          config: AttriaxConfig(
            projectToken: 'ax_test_token',
            attestationEnabled: true,
            attestationProvider: _StubAttestationProvider((nonce) {
              providerCalls += 1;
              return AttriaxAttestationEnvelope(
                provider: AttriaxAttestationProviderSlug.playIntegrity,
                token: 'integrity_token',
                nonce: nonce,
              );
            }),
          ),
          fetchChallenge: () async => null,
          logger: quietLogger(),
        );

        expect(await manager.resolveEnvelope(), isNull);
        expect(providerCalls, 0);
      },
    );

    test(
      'enabled + challenge fetch throws → resolves to null (never throws)',
      () async {
        final manager = AttriaxAttestationManager(
          config: AttriaxConfig(
            projectToken: 'ax_test_token',
            attestationEnabled: true,
            attestationProvider: _StubAttestationProvider(
              (nonce) => AttriaxAttestationEnvelope(
                provider: AttriaxAttestationProviderSlug.playIntegrity,
                token: 'integrity_token',
                nonce: nonce,
              ),
            ),
          ),
          fetchChallenge: () async =>
              throw StateError('challenge endpoint unreachable'),
          logger: quietLogger(),
        );

        expect(await manager.resolveEnvelope(), isNull);
      },
    );

    test(
      'enabled without a provider defaults to noop → resolves to null',
      () async {
        final manager = AttriaxAttestationManager(
          config: const AttriaxConfig(
            projectToken: 'ax_test_token',
            attestationEnabled: true,
          ),
          fetchChallenge: () async =>
              const AttriaxAttestationChallenge(nonce: 'server_nonce'),
          logger: quietLogger(),
        );

        expect(manager.isEnabled, isTrue);
        expect(await manager.resolveEnvelope(), isNull);
      },
    );

    test('includes keyId for App Attest envelopes', () async {
      final manager = AttriaxAttestationManager(
        config: AttriaxConfig(
          projectToken: 'ax_test_token',
          attestationEnabled: true,
          attestationProvider: _StubAttestationProvider(
            (nonce) => AttriaxAttestationEnvelope(
              provider: AttriaxAttestationProviderSlug.appAttest,
              token: 'app_attest_token',
              nonce: nonce,
              keyId: 'key_abc',
            ),
          ),
        ),
        fetchChallenge: () async =>
            const AttriaxAttestationChallenge(nonce: 'server_nonce'),
        logger: quietLogger(),
      );

      expect(await manager.resolveEnvelope(), <String, Object?>{
        'provider': 'app_attest',
        'token': 'app_attest_token',
        'nonce': 'server_nonce',
        'keyId': 'key_abc',
      });
    });
  });
}

class _StubAttestationProvider implements AttriaxAttestationProvider {
  _StubAttestationProvider(this._attest);

  final AttriaxAttestationEnvelope? Function(String nonce) _attest;

  @override
  Future<AttriaxAttestationEnvelope?> attest(String nonce) async =>
      _attest(nonce);
}
