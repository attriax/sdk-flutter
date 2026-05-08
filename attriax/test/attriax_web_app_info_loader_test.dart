import 'package:attriax_flutter/src/internal/attriax_web_app_info_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds version.json urls from routed and html entry URLs', () {
    final loader = AttriaxWebAppInfoLoader(
      baseUrlProviders: <AttriaxWebBaseUrlProvider>[],
    );

    expect(
      loader
          .buildVersionJsonUrl(
            'https://demo.attriax.com/index.html?utm=1#fragment',
            42,
          )
          .toString(),
      'https://demo.attriax.com/version.json?cachebuster=42',
    );
    expect(
      loader
          .buildVersionJsonUrl('https://demo.attriax.com/app/install', 42)
          .toString(),
      'https://demo.attriax.com/app/version.json?cachebuster=42',
    );
    expect(
      loader
          .buildVersionJsonUrl('https://demo.attriax.com/embedded/', 42)
          .toString(),
      'https://demo.attriax.com/embedded/version.json?cachebuster=42',
    );
  });

  test(
    'loads web app metadata from the first successful version.json response',
    () async {
      final client = MockClient((request) async {
        if (request.url.toString() ==
            'https://demo.attriax.com/version.json?cachebuster=7') {
          return http.Response('not found', 404);
        }
        if (request.url.toString() ==
            'https://demo.attriax.com/app/version.json?cachebuster=7') {
          return http.Response(
            '{"version":"2.4.6","build_number":"19","package_name":"com.example.web"}',
            200,
          );
        }

        return http.Response('unexpected', 500);
      });

      final loader = AttriaxWebAppInfoLoader(
        client: client,
        cacheBusterFactory: () => 7,
        baseUrlProviders: <AttriaxWebBaseUrlProvider>[
          () => 'https://demo.attriax.com/',
          () => 'https://demo.attriax.com/app/index.html',
        ],
      );

      final snapshot = await loader.load();

      expect(snapshot?.version, '2.4.6');
      expect(snapshot?.buildNumber, '19');
      expect(snapshot?.packageName, 'com.example.web');
    },
  );
}
