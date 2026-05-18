import 'package:attriax_flutter/src/internal/attriax_api_base_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeAttriaxApiBaseUrl', () {
    test('preserves a direct HTTPS base URL', () {
      final normalized = normalizeAttriaxApiBaseUrl('https://api.attriax.com');

      expect(normalized.apiBaseUrl, 'https://api.attriax.com');
    });

    test('normalizes /api and /api/sdk suffixes to the root API host', () {
      expect(
        normalizeAttriaxApiBaseUrl('https://api.attriax.com/api').apiBaseUrl,
        'https://api.attriax.com',
      );
      expect(
        normalizeAttriaxApiBaseUrl(
          'https://api.attriax.com/api/sdk/',
        ).apiBaseUrl,
        'https://api.attriax.com',
      );
    });

    test('allows HTTP localhost and IPv6 loopback for development', () {
      expect(
        normalizeAttriaxApiBaseUrl('http://localhost:3000').apiBaseUrl,
        'http://localhost:3000',
      );
      expect(
        normalizeAttriaxApiBaseUrl('http://127.0.0.1:3000').apiBaseUrl,
        'http://127.0.0.1:3000',
      );
      expect(
        normalizeAttriaxApiBaseUrl('http://[::1]:3000').apiBaseUrl,
        'http://[::1]:3000',
      );
    });

    test('can emit a warning for loopback URLs outside debug usage', () {
      final warnings = <String>[];

      final normalized = normalizeAttriaxApiBaseUrl(
        'http://localhost:3000/api',
        warnOnLocalhost: true,
        onWarning: warnings.add,
      );

      expect(normalized.apiBaseUrl, 'http://localhost:3000');
      expect(warnings, <String>[
        'Attriax apiBaseUrl points to a loopback endpoint. This is intended for development only and will not work from released apps unless the device can reach that local host.',
      ]);
    });

    test('can emit the same warning for HTTPS loopback URLs', () {
      final warnings = <String>[];

      final normalized = normalizeAttriaxApiBaseUrl(
        'https://127.0.0.1:8443/api',
        warnOnLocalhost: true,
        onWarning: warnings.add,
      );

      expect(normalized.apiBaseUrl, 'https://127.0.0.1:8443');
      expect(warnings, <String>[
        'Attriax apiBaseUrl points to a loopback endpoint. This is intended for development only and will not work from released apps unless the device can reach that local host.',
      ]);
    });

    test('rejects insecure remote API endpoints', () {
      expect(
        () => normalizeAttriaxApiBaseUrl('http://api.attriax.com'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Attriax apiBaseUrl must use HTTPS unless it targets localhost.',
          ),
        ),
      );
    });
  });
}
