import 'package:shared_preferences/shared_preferences.dart';

class ExampleAppConfiguration {
  const ExampleAppConfiguration({required this.appToken, this.apiBaseUrl});

  final String appToken;
  final String? apiBaseUrl;

  String? get displayApiBaseUrl => _sanitizeExampleConfigValue(apiBaseUrl);

  String? get normalizedApiBaseUrl => normalizeExampleApiBaseUrl(apiBaseUrl);
}

class ExampleAppConfigurationStore {
  ExampleAppConfigurationStore({
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader = preferencesLoader;

  static const String appTokenStorageKey = 'attriax_flutter_example.app_token';
  static const String apiBaseUrlStorageKey =
      'attriax_flutter_example.api_base_url';

  final Future<SharedPreferences> Function()? _preferencesLoader;

  Future<ExampleAppConfiguration?> load() async {
    final prefs = await _preferences();
    final appToken = _sanitizeExampleConfigValue(
      prefs.getString(appTokenStorageKey),
    );
    if (appToken == null) {
      return null;
    }

    return ExampleAppConfiguration(
      appToken: appToken,
      apiBaseUrl: _sanitizeExampleConfigValue(
        prefs.getString(apiBaseUrlStorageKey),
      ),
    );
  }

  Future<void> save(ExampleAppConfiguration configuration) async {
    final prefs = await _preferences();
    await prefs.setString(appTokenStorageKey, configuration.appToken.trim());

    final apiBaseUrl = configuration.normalizedApiBaseUrl;
    if (apiBaseUrl == null) {
      await prefs.remove(apiBaseUrlStorageKey);
      return;
    }

    await prefs.setString(apiBaseUrlStorageKey, apiBaseUrl);
  }

  Future<void> clear() async {
    final prefs = await _preferences();
    await prefs.remove(appTokenStorageKey);
    await prefs.remove(apiBaseUrlStorageKey);
  }

  Future<SharedPreferences> _preferences() =>
      (_preferencesLoader ?? SharedPreferences.getInstance)();
}

String? _sanitizeExampleConfigValue(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? normalizeExampleApiBaseUrl(String? value) {
  final sanitized = _sanitizeExampleConfigValue(value);
  if (sanitized == null) {
    return null;
  }

  final normalized = sanitized.replaceFirst(RegExp(r'/+$'), '');
  final apiUri = Uri.tryParse(normalized);
  if (apiUri == null || !apiUri.hasScheme || !apiUri.hasAuthority) {
    throw ArgumentError('API base URL must be an absolute URL.');
  }

  final host = _normalizeExampleHost(apiUri.host);
  final isLocalhost =
      host == 'localhost' || host == '127.0.0.1' || host == '::1';
  if (apiUri.scheme != 'https' && !(isLocalhost && apiUri.scheme == 'http')) {
    throw ArgumentError(
      'API base URL must use HTTPS unless it targets localhost.',
    );
  }

  return _normalizeExampleApiBasePath(normalized);
}

String _normalizeExampleApiBasePath(String value) {
  if (value.endsWith('/api/sdk')) {
    return value.substring(0, value.length - '/api/sdk'.length);
  }
  if (value.endsWith('/api')) {
    return value.substring(0, value.length - '/api'.length);
  }
  return value;
}

String _normalizeExampleHost(String host) {
  if (host.startsWith('[') && host.endsWith(']')) {
    return host.substring(1, host.length - 1);
  }
  return host;
}
