import 'package:attriax_flutter/src/internal/attriax_web_app_info_loader.dart';
import 'package:attriax_flutter/src/internal/attriax_web_environment_stub.dart';
import 'package:attriax_flutter/src/internal/attriax_web_platform.dart';
import 'test_support/attriax_platform_test_support.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'collectNativeContext returns browser metadata and discovered app info',
    () async {
      final platform = AttriaxWebPlatform(
        environmentProvider: () => const AttriaxWebEnvironmentSnapshot(
          assetBaseUrl: 'https://demo.attriax.com/app/',
          documentBaseUrl: 'https://demo.attriax.com/app/index.html',
          locationBaseUrl: 'https://demo.attriax.com/app/install?code=1',
          timezone: 'Europe/Berlin',
          appName: 'Netscape',
          browserName: 'Mozilla',
          userAgent: 'Mozilla/5.0 Test',
          platform: 'macOS',
          vendor: 'Attriax Browser',
          title: 'Attriax Demo',
          referrer: 'https://search.example.com/',
        ),
        appInfoLoaderFactory: (_) => _FakeWebAppInfoLoader(),
      );

      final context = await platform.collectNativeContext();

      expect(context.metadata['appVersion'], '4.5.6');
      expect(context.metadata['appBuildNumber'], '21');
      expect(context.metadata['packageName'], 'com.example.attriax.web');
      expect(context.metadata['timezone'], 'Europe/Berlin');
      expect(context.metadata['browserName'], 'Mozilla');
      expect(context.metadata['title'], 'Attriax Demo');
      expect(
        context.metadata['url'],
        'https://demo.attriax.com/app/install?code=1',
      );
    },
  );
}

class _FakeWebAppInfoLoader extends AttriaxWebAppInfoLoader {
  _FakeWebAppInfoLoader()
    : super(baseUrlProviders: const <AttriaxWebBaseUrlProvider>[]);

  @override
  Future<AttriaxAppSnapshot?> load() async => const AttriaxAppSnapshot(
    version: '4.5.6',
    buildNumber: '21',
    packageName: 'com.example.attriax.web',
  );
}
