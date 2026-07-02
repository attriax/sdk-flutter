import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import '../attriax_platform_types.dart'
    show
        AttriaxAttestationEnvelope,
        AttriaxAttestationProvider,
        AttriaxAttestationProviderSlug,
        AttriaxPlatformType,
        attriaxAttestationProviderSlugForPlatform;

/// The method-channel name the native attestation stubs answer on.
///
/// Kept separate from the main `attriax` channel so the native attestation
/// handlers can be added (or stay stubbed) independently, and so a missing
/// native handler degrades to a clean [MissingPluginException] → `null`.
const String attriaxAttestationMethodChannelName = 'attriax/attestation';

/// The method a native provider implements to acquire an attestation token.
const String attriaxAcquireAttestationTokenMethod = 'acquireAttestationToken';

/// An [AttriaxAttestationProvider] that acquires a token over a platform
/// method channel.
///
/// Dart side (REAL, tested): resolves the provider slug from the current
/// platform, invokes the native `acquireAttestationToken` method with the
/// server nonce and expected provider, and assembles an
/// [AttriaxAttestationEnvelope] from the native result.
///
/// Native side (TODO(live)): the Android (Play Integrity) and iOS (App Attest)
/// handlers are stubbed and currently return no token, so this provider yields
/// `null` and the SDK degrades to "unattested" cleanly. See the platform plugin
/// sources for the `TODO(live)` acquisition seams.
///
/// Any native error or a missing handler is swallowed and reported as `null` —
/// attestation must never break init.
class AttriaxPlatformAttestationProvider implements AttriaxAttestationProvider {
  AttriaxPlatformAttestationProvider({
    required AttriaxPlatformType Function() currentPlatform,
    MethodChannel? channel,
    String logName = 'attriax.attestation',
  }) : _currentPlatform = currentPlatform,
       _channel =
           channel ?? const MethodChannel(attriaxAttestationMethodChannelName),
       _logName = logName;

  final AttriaxPlatformType Function() _currentPlatform;
  final MethodChannel _channel;
  final String _logName;

  @override
  Future<AttriaxAttestationEnvelope?> attest(String nonce) async {
    final trimmedNonce = nonce.trim();
    if (trimmedNonce.isEmpty) {
      return null;
    }

    final provider = attriaxAttestationProviderSlugForPlatform(
      _currentPlatform(),
    );
    if (provider == null) {
      // No native attestation provider exists for this platform (web/desktop).
      return null;
    }

    final Object? result;
    try {
      result = await _channel.invokeMethod<Object?>(
        attriaxAcquireAttestationTokenMethod,
        <String, Object?>{'nonce': trimmedNonce, 'provider': provider},
      );
    } on MissingPluginException catch (error, stackTrace) {
      // No native handler registered yet (TODO(live) stubs). Degrade cleanly.
      _log('missing native attestation handler', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _log('native attestation failed', error, stackTrace);
      return null;
    }

    return _envelopeFromNativeResult(
      nonce: trimmedNonce,
      fallbackProvider: provider,
      result: result,
    );
  }

  AttriaxAttestationEnvelope? _envelopeFromNativeResult({
    required String nonce,
    required String fallbackProvider,
    required Object? result,
  }) {
    if (result is! Map) {
      return null;
    }

    final token = _stringOrNull(result['token']);
    if (token == null) {
      // A native stub that could not attest returns no token.
      return null;
    }

    // The native side may echo back its own provider slug and (for App Attest) a
    // key id. Fall back to the platform-derived slug when the native slug is
    // absent, and normalize any unexpected slug to the platform default. The
    // nonce always comes from the SDK-issued challenge, not the native side, so
    // the server can match the single-use nonce it issued.
    final nativeProvider = _stringOrNull(result['provider']);
    final provider = _normalizeProvider(nativeProvider) ?? fallbackProvider;

    return AttriaxAttestationEnvelope(
      provider: provider,
      token: token,
      nonce: nonce,
      keyId: _stringOrNull(result['keyId']),
    );
  }

  String? _normalizeProvider(String? provider) {
    switch (provider) {
      case AttriaxAttestationProviderSlug.playIntegrity:
      case AttriaxAttestationProviderSlug.appAttest:
        return provider;
      default:
        return null;
    }
  }

  String? _stringOrNull(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _log(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: _logName,
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }
}
