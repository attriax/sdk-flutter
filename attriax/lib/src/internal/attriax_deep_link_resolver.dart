import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

class AttriaxDeepLinkResolver {
  const AttriaxDeepLinkResolver();

  String? normalizeLinkPath(String? path) {
    if (path == null) {
      return null;
    }
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final normalized = trimmed
        .replaceFirst(RegExp('^/+'), '')
        .replaceFirst(RegExp(r'/+$'), '');
    return normalized.isEmpty ? null : normalized;
  }

  AttriaxDeepLinkResolution buildResolution(
    AttriaxDeepLinkResolutionResult result, {
    required DateTime clickedAt,
  }) {
    final canonicalUri =
        result.deepLink?.uri ??
        _uriFromNormalizedPath(normalizeLinkPath(result.deepLink?.path));

    return AttriaxDeepLinkResolution(
      uri: canonicalUri,
      clickedAt: clickedAt,
      consumedAt:
          result.consumedAt ?? result.acceptedAt ?? DateTime.now().toUtc(),
      found: result.matched,
      data: stringifyData(result.deepLink?.data),
      utm: result.deepLink?.utm,
    );
  }

  String? extractLinkPathFromUri(Uri uri) {
    final candidate = uri.path.isNotEmpty && uri.path != '/'
        ? uri.path
        : uri.host;
    return normalizeLinkPath(candidate);
  }

  bool isAttriaxDomain(Uri uri) {
    final host = uri.host.trim().toLowerCase();
    return host.isNotEmpty && host.endsWith('.attriax.com');
  }

  Uri buildDeferredUri(AttriaxAppOpenResult result) {
    final deferredUri =
        result.deepLink?.uri ??
        result.reinstallReferrer?.deepLinkUri ??
        result.installReferrer?.deepLinkUri ??
        (result.installReferrer?.deepLinkUrl == null
            ? null
            : Uri.tryParse(result.installReferrer!.deepLinkUrl!));
    if (deferredUri != null) {
      return deferredUri;
    }

    return _uriFromNormalizedPath(normalizeLinkPath(result.deepLink?.path));
  }

  AttriaxDeepLinkResolution buildDeferredResolution(
    AttriaxAppOpenResult result, {
    required DateTime fallbackTime,
  }) {
    return AttriaxDeepLinkResolution(
      uri: buildDeferredUri(result),
      clickedAt: result.deepLinkClickedAt ?? result.acceptedAt ?? fallbackTime,
      consumedAt:
          result.deepLinkConsumedAt ?? result.acceptedAt ?? fallbackTime,
      found: result.deepLink != null,
      data: stringifyData(
        result.deepLink?.data ??
            result.reinstallReferrer?.deepLinkData ??
            result.installReferrer?.deepLinkData,
      ),
      utm:
          result.deepLink?.utm ??
          result.reinstallReferrer?.utm ??
          result.installReferrer?.utm,
    );
  }

  Map<String, String>? stringifyData(Map<String, Object?>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }

    return <String, String>{
      for (final entry in data.entries)
        entry.key: entry.value == null ? '' : entry.value.toString(),
    };
  }

  Uri _uriFromNormalizedPath(String? normalizedPath) =>
      Uri(path: normalizedPath == null ? '/' : '/$normalizedPath');
}
