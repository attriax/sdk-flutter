import 'dart:convert';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:http/http.dart' as http;

typedef AttriaxWebBaseUrlProvider = String? Function();

class AttriaxWebAppInfoLoader {
  AttriaxWebAppInfoLoader({
    http.Client? client,
    List<AttriaxWebBaseUrlProvider>? baseUrlProviders,
    int Function()? cacheBusterFactory,
  }) : _client = client,
       _baseUrlProviders =
           baseUrlProviders ?? const <AttriaxWebBaseUrlProvider>[],
       _cacheBusterFactory =
           cacheBusterFactory ?? (() => DateTime.now().millisecondsSinceEpoch);

  final http.Client? _client;
  final List<AttriaxWebBaseUrlProvider> _baseUrlProviders;
  final int Function() _cacheBusterFactory;

  Future<AttriaxAppSnapshot?> load() async {
    final cacheBuster = _cacheBusterFactory();
    final attemptedUrls = <String>{};

    for (final provider in _baseUrlProviders) {
      final baseUrl = provider();
      if (baseUrl == null || baseUrl.isEmpty) {
        continue;
      }

      final url = buildVersionJsonUrl(baseUrl, cacheBuster);
      if (!attemptedUrls.add(url.toString())) {
        continue;
      }

      final versionMap = await _fetchVersionMap(url);
      if (versionMap == null) {
        continue;
      }

      final snapshot = AttriaxAppSnapshot(
        version: _stringValue(versionMap['version']),
        buildNumber:
            _stringValue(versionMap['build_number']) ??
            _stringValue(versionMap['buildNumber']),
        packageName:
            _stringValue(versionMap['package_name']) ??
            _stringValue(versionMap['packageName']),
      );

      if (snapshot.version != null ||
          snapshot.buildNumber != null ||
          snapshot.packageName != null) {
        return snapshot;
      }
    }

    return null;
  }

  Uri buildVersionJsonUrl(String baseUrl, int cacheBuster) {
    final fragmentIndex = baseUrl.indexOf('#');
    final sanitizedBaseUrl = fragmentIndex >= 0
        ? baseUrl.substring(0, fragmentIndex)
        : baseUrl;
    final uri = Uri.parse(sanitizedBaseUrl).replace(query: '');
    final pathSegments = <String>[...uri.pathSegments];

    if (pathSegments.isNotEmpty) {
      final lastSegment = pathSegments.last;
      final looksLikeHtml = RegExp(r'[^/]+\.html$').hasMatch(lastSegment);
      final shouldTrimLastSegment =
          looksLikeHtml ||
          ((uri.isScheme('http') || uri.isScheme('https')) &&
              uri.path.length > 1 &&
              !uri.path.endsWith('/'));

      if (shouldTrimLastSegment) {
        pathSegments.removeLast();
      }
    }

    pathSegments.removeWhere((segment) => segment.isEmpty);
    return uri.replace(
      pathSegments: <String>[...pathSegments, 'version.json'],
      queryParameters: <String, String>{'cachebuster': '$cacheBuster'},
    );
  }

  Future<Map<String, dynamic>?> _fetchVersionMap(Uri url) async {
    try {
      final response = _client == null
          ? await http.get(url)
          : await _client.get(url);
      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num) {
      return value.toString();
    }

    return null;
  }
}
