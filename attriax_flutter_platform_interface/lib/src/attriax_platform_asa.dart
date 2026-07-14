import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import '../attriax_platform_types.dart' show AttriaxPlatformType;

/// The method-channel name the native Apple Search Ads (AdServices) stub
/// answers on.
///
/// Kept separate from the main `attriax` channel (mirroring the
/// `attriax/attestation` seam) so the native AdServices handler can be added
/// (or stay stubbed) independently, and so a missing native handler degrades to
/// a clean [MissingPluginException] → `null`.
const String attriaxAsaMethodChannelName = 'attriax/asa';

/// The method a native provider implements to acquire an AdServices token.
const String attriaxAcquireAdServicesTokenMethod = 'acquireAdServicesToken';

/// Acquires the Apple Search Ads (AdServices) attribution token over a platform
/// method channel.
///
/// Dart side (REAL, tested): on iOS it invokes the native
/// `acquireAdServicesToken` method and returns the trimmed token string; on any
/// non-iOS platform it short-circuits to `null` without touching the channel.
///
/// Native side (TODO(live)): the iOS handler is stubbed and currently returns no
/// token, so this provider yields `null` and the SDK degrades to "no ASA token"
/// cleanly. The live seam will call `AAAttribution.attributionToken()`. See the
/// iOS plugin source for the `TODO(live)` acquisition seam.
///
/// Any native error or a missing handler is swallowed and reported as `null` —
/// ASA token capture is best-effort and must never affect init or session.
class AttriaxAdServicesTokenProvider {
  AttriaxAdServicesTokenProvider({
    required AttriaxPlatformType Function() currentPlatform,
    MethodChannel? channel,
    String logName = 'attriax.asa',
  }) : _currentPlatform = currentPlatform,
       _channel = channel ?? const MethodChannel(attriaxAsaMethodChannelName),
       _logName = logName;

  final AttriaxPlatformType Function() _currentPlatform;
  final MethodChannel _channel;
  final String _logName;

  /// Attempts to acquire the AdServices attribution token.
  ///
  /// Returns `null` when the platform has no AdServices provider (non-iOS), the
  /// native handler is a stub/unimplemented, or any error occurs. Never throws.
  Future<String?> acquireToken() async {
    if (_currentPlatform() != AttriaxPlatformType.ios) {
      // AdServices (Apple Search Ads) only exists on iOS. Do not touch the
      // channel on other platforms.
      return null;
    }

    final Object? result;
    try {
      result = await _channel.invokeMethod<Object?>(
        attriaxAcquireAdServicesTokenMethod,
      );
    } on MissingPluginException catch (error, stackTrace) {
      // No native handler registered yet (TODO(live) stub). Degrade cleanly.
      _log('missing native AdServices handler', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _log('native AdServices token acquisition failed', error, stackTrace);
      return null;
    }

    return _tokenFromNativeResult(result);
  }

  String? _tokenFromNativeResult(Object? result) {
    // The native side may return the token directly as a string, or wrap it in
    // a `{ "token": ... }` map (mirroring the attestation seam). Accept both.
    if (result is String) {
      return _stringOrNull(result);
    }
    if (result is Map) {
      return _stringOrNull(result['token']);
    }
    return null;
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
