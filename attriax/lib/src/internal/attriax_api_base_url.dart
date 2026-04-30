class AttriaxNormalizedApiBaseUrl {
  const AttriaxNormalizedApiBaseUrl({required this.apiBaseUrl});

  final String apiBaseUrl;
}

AttriaxNormalizedApiBaseUrl normalizeAttriaxApiBaseUrl(String value) {
  final normalized = value.trim().replaceFirst(RegExp(r'/+$'), '');
  final apiUri = Uri.tryParse(normalized);
  if (apiUri == null || !apiUri.hasScheme || !apiUri.hasAuthority) {
    throw ArgumentError('Attriax apiBaseUrl must be an absolute URL.');
  }

  final host = _normalizeHost(apiUri.host);
  final isLocalhost =
      host == 'localhost' || host == '127.0.0.1' || host == '::1';
  if (apiUri.scheme != 'https' && !(isLocalhost && apiUri.scheme == 'http')) {
    throw ArgumentError(
      'Attriax apiBaseUrl must use HTTPS unless it targets localhost.',
    );
  }

  return AttriaxNormalizedApiBaseUrl(
    apiBaseUrl: _normalizeApiBasePath(normalized),
  );
}

String _normalizeApiBasePath(String value) {
  if (value.endsWith('/api/sdk')) {
    return value.substring(0, value.length - '/api/sdk'.length);
  }
  if (value.endsWith('/api')) {
    return value.substring(0, value.length - '/api'.length);
  }
  return value;
}

String _normalizeHost(String host) {
  if (host.startsWith('[') && host.endsWith(']')) {
    return host.substring(1, host.length - 1);
  }
  return host;
}
