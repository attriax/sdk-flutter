import 'dart:async';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_logger.dart';

/// Acquires an AdServices token from the native seam. Returns `null` when the
/// platform has no provider, the native handler is a stub, or an error occurs.
typedef AttriaxAsaTokenAcquirer = Future<String?> Function();

/// POSTs the acquired ASA token to the API. Best-effort; may throw on network or
/// non-success status — the manager swallows any failure.
typedef AttriaxAsaTokenSender =
    Future<void> Function({required String projectToken, required String token});

/// Orchestrates the SDK-side Apple Search Ads (AdServices) token capture flow
/// (Epic 8.5).
///
/// iOS-only and best-effort: at startup it asks the native provider for the
/// AdServices attribution token and, if one is available, POSTs it to
/// `POST /api/sdk/v1/asa/token`. Everything degrades to a silent no-op:
/// - a non-iOS platform never runs (the acquirer returns `null`);
/// - a stub/unimplemented native handler yields `null` → nothing is sent;
/// - any thrown error (acquisition or network) is caught and logged at verbose.
///
/// This mirrors the attestation manager's "never break init" invariant: ASA
/// token capture must never block, fail, or otherwise affect init or session.
class AttriaxAsaTokenManager {
  AttriaxAsaTokenManager({
    required AttriaxConfig config,
    required AttriaxPlatformType platformType,
    required AttriaxAsaTokenAcquirer acquireToken,
    required AttriaxAsaTokenSender sendToken,
    required AttriaxLogger logger,
  }) : _projectToken = config.projectToken,
       _platformType = platformType,
       _acquireToken = acquireToken,
       _sendToken = sendToken,
       _logger = logger;

  final String _projectToken;
  final AttriaxPlatformType _platformType;
  final AttriaxAsaTokenAcquirer _acquireToken;
  final AttriaxAsaTokenSender _sendToken;
  final AttriaxLogger _logger;

  bool _didRun = false;

  /// Whether this SDK instance can attempt ASA token capture (iOS only).
  bool get isSupported => _platformType == AttriaxPlatformType.ios;

  /// Acquires and reports the AdServices token, at most once per runtime.
  ///
  /// Never throws. Resolves without side effects when unsupported, already run,
  /// no token is available, or any error occurs.
  Future<void> captureAndReportIfNeeded() async {
    if (_didRun || !isSupported) {
      return;
    }
    _didRun = true;

    try {
      final token = await _acquireToken();
      final normalizedToken = token?.trim();
      if (normalizedToken == null || normalizedToken.isEmpty) {
        _logger.verbose(
          'No Apple Search Ads token available; skipping ASA token report.',
        );
        return;
      }

      await _sendToken(projectToken: _projectToken, token: normalizedToken);
      _logger.verbose('Reported Apple Search Ads token.');
    } catch (error, stackTrace) {
      // ASA token capture is best-effort — never let it break init or session.
      _logger.warning(
        'Apple Search Ads token capture failed; continuing without an ASA '
        'token report.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
