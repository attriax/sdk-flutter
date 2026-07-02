import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_logger.dart';

/// The single-use challenge issued by `POST /api/sdk/attestation/challenge`.
class AttriaxAttestationChallenge {
  const AttriaxAttestationChallenge({
    required this.nonce,
    this.expiresInSeconds,
  });

  final String nonce;
  final int? expiresInSeconds;
}

/// Orchestrates the SDK-side device-attestation flow (Epic 7.3b).
///
/// Enabled only when [AttriaxConfig.attestationEnabled] is `true`. When enabled,
/// [resolveEnvelope] fetches a nonce from the challenge endpoint, asks the
/// configured provider to produce an attestation token, and returns the
/// assembled envelope map for attachment to the init request.
///
/// The whole flow is best-effort and defensive: a disabled config, a failed
/// challenge fetch, a `null` provider result, or any thrown error all resolve to
/// `null`, which means the init request is sent with NO envelope. Attestation
/// must never block or fail init — this mirrors the server's "never break the
/// install" invariant.
class AttriaxAttestationManager {
  AttriaxAttestationManager({
    required AttriaxConfig config,
    required Future<AttriaxAttestationChallenge?> Function() fetchChallenge,
    required AttriaxLogger logger,
  }) : _enabled = config.attestationEnabled,
       _provider =
           config.attestationProvider ??
           const AttriaxNoopAttestationProvider(),
       _fetchChallenge = fetchChallenge,
       _logger = logger;

  final bool _enabled;
  final AttriaxAttestationProvider _provider;
  final Future<AttriaxAttestationChallenge?> Function() _fetchChallenge;
  final AttriaxLogger _logger;

  /// Whether attestation is opted in for this SDK instance.
  bool get isEnabled => _enabled;

  /// Resolves the attestation envelope to attach to the init request.
  ///
  /// Returns `null` (→ attach nothing) when attestation is disabled, the
  /// challenge could not be fetched, the provider returned `null`, or any error
  /// occurred. Never throws.
  Future<Map<String, Object?>?> resolveEnvelope() async {
    if (!_enabled) {
      return null;
    }

    try {
      final challenge = await _fetchChallenge();
      if (challenge == null) {
        _logger.verbose(
          'Attestation challenge unavailable; sending init without an '
          'attestation envelope.',
        );
        return null;
      }

      final envelope = await _provider.attest(challenge.nonce);
      if (envelope == null) {
        _logger.verbose(
          'Attestation provider returned no token; sending init without an '
          'attestation envelope.',
        );
        return null;
      }

      return envelope.toJson();
    } catch (error, stackTrace) {
      // Attestation is best-effort — never let it break init.
      _logger.warning(
        'Attestation resolution failed; sending init without an attestation '
        'envelope.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
