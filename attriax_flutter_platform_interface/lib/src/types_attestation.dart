part of 'types.dart';

/// Canonical Attriax device-attestation provider slugs.
///
/// These match the server contract (Epic 7.3a): Play Integrity on Android and
/// App Attest on Apple platforms. The server treats any other/absent value as
/// `attestation_missing`, so the SDK only ever emits these two slugs.
abstract final class AttriaxAttestationProviderSlug {
  /// Android Play Integrity attestation.
  static const String playIntegrity = 'play_integrity';

  /// Apple App Attest attestation.
  static const String appAttest = 'app_attest';
}

/// Maps a runtime platform to the attestation provider slug it can produce.
///
/// Returns `null` for platforms that have no supported native attestation
/// provider (web/desktop). A `null` result means the SDK will not attempt to
/// attest and simply sends no envelope, which the server reads as
/// `attestation_missing` (only penalized when the project opts into
/// `requireAttestation`).
String? attriaxAttestationProviderSlugForPlatform(
  AttriaxPlatformType platform,
) {
  switch (platform) {
    case AttriaxPlatformType.android:
      return AttriaxAttestationProviderSlug.playIntegrity;
    case AttriaxPlatformType.ios:
    case AttriaxPlatformType.macos:
      return AttriaxAttestationProviderSlug.appAttest;
    case AttriaxPlatformType.web:
    case AttriaxPlatformType.windows:
    case AttriaxPlatformType.linux:
    case AttriaxPlatformType.unknown:
      return null;
  }
}

/// The OPTIONAL device-attestation envelope attached to the SDK init request.
///
/// Mirrors the server contract (Epic 7.3a): a partial or absent envelope is
/// accepted and degrades to `attestation_missing`; it is only verified when the
/// project opts into `requireAttestation`. An unattested client omits it
/// entirely, so there is zero behavior change for existing integrations.
class AttriaxAttestationEnvelope {
  const AttriaxAttestationEnvelope({
    required this.provider,
    required this.token,
    required this.nonce,
    this.keyId,
  });

  /// Provider slug — `play_integrity` (Android) or `app_attest` (Apple).
  final String provider;

  /// The OS attestation token/blob obtained from the native provider.
  final String token;

  /// The single-use nonce previously issued by the challenge endpoint.
  final String nonce;

  /// App Attest key id. Present for App Attest, `null` for Play Integrity.
  final String? keyId;

  /// Serializes the envelope for attachment to the init request body.
  ///
  /// `keyId` is only included when present, matching the server DTO where every
  /// sub-field is optional.
  Map<String, Object?> toJson() => <String, Object?>{
    'provider': provider,
    'token': token,
    'nonce': nonce,
    if (keyId != null) 'keyId': keyId,
  };
}

/// Produces a device-attestation envelope for a server-issued `nonce`.
///
/// Implementations acquire a platform attestation token (Play Integrity / App
/// Attest) that embeds the `nonce`, then assemble an
/// [AttriaxAttestationEnvelope].
///
/// Returning `null` is a first-class, expected outcome: it means attestation is
/// unavailable on this device/platform (no native provider, an OS error, or a
/// stub build). The SDK then sends the init request with NO envelope. An
/// implementation must never throw for an unavailable provider — the SDK's
/// attestation flow catches errors defensively, but a well-behaved provider
/// degrades to `null`.
// ignore: one_member_abstracts
abstract interface class AttriaxAttestationProvider {
  /// Attempts to attest against [nonce]. Returns `null` when unavailable.
  Future<AttriaxAttestationEnvelope?> attest(String nonce);
}

/// The shipped default provider: always returns `null` (no attestation).
///
/// This is what an SDK instance uses unless the integration explicitly opts in
/// and supplies a real provider, guaranteeing that attestation is inert by
/// default.
class AttriaxNoopAttestationProvider implements AttriaxAttestationProvider {
  const AttriaxNoopAttestationProvider();

  @override
  Future<AttriaxAttestationEnvelope?> attest(String nonce) async => null;
}
