import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

const attriaxIosWkWebViewUserAgentMetadataKey = 'wkWebViewUserAgent';
const _attriaxClipboardClickIdParam = 'attriax_click_id';

class AttriaxIosAppOpenEnrichmentManager {
  AttriaxIosAppOpenEnrichmentManager({
    required AttriaxPlatform platform,
    required AttriaxPlatformType platformType,
  }) : _platform = platform,
       _platformType = platformType;

  final AttriaxPlatform _platform;
  final AttriaxPlatformType _platformType;

  bool _didAttemptClipboardCapture = false;
  String? _capturedInstallReferrer;

  Future<void> primeForConsentState({
    required bool clipboardAttributionEnabled,
    required bool isWaitingForGdprConsent,
    required bool allowsAttributionTracking,
  }) async {
    if (_platformType != AttriaxPlatformType.ios) {
      return;
    }

    if (!clipboardAttributionEnabled) {
      return;
    }

    if (!isWaitingForGdprConsent && !allowsAttributionTracking) {
      return;
    }

    if (_didAttemptClipboardCapture) {
      return;
    }

    _didAttemptClipboardCapture = true;
    final clipboardText = await _platform.readAttributionClipboard();
    _capturedInstallReferrer = _normalizeInstallReferrer(clipboardText);
  }

  String? installReferrerOverrideForAppOpen({
    required bool clipboardAttributionEnabled,
    required bool allowsAttributionTracking,
  }) => clipboardAttributionEnabled && allowsAttributionTracking
      ? _capturedInstallReferrer
      : null;

  Future<Map<String, Object?>> buildDeviceMetadataOverridesForAppOpen({
    required bool allowsAttributionTracking,
  }) async {
    if (_platformType != AttriaxPlatformType.ios ||
        !allowsAttributionTracking) {
      return const <String, Object?>{};
    }

    final webViewUserAgent = await _platform.collectWebViewUserAgent();
    if (webViewUserAgent == null || webViewUserAgent.isEmpty) {
      return const <String, Object?>{};
    }

    return <String, Object?>{
      attriaxIosWkWebViewUserAgentMetadataKey: webViewUserAgent,
    };
  }

  void reset() {
    _didAttemptClipboardCapture = false;
    _capturedInstallReferrer = null;
  }

  String? _normalizeInstallReferrer(String? clipboardText) {
    final trimmed = clipboardText?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    final query = uri?.query.trim();
    if (query != null && query.isNotEmpty) {
      return query;
    }

    final normalized = trimmed.startsWith('?') ? trimmed.substring(1) : trimmed;
    if (normalized.contains('=') || normalized.contains('&')) {
      return normalized;
    }

    return '$_attriaxClipboardClickIdParam=${Uri.encodeQueryComponent(trimmed)}';
  }
}
