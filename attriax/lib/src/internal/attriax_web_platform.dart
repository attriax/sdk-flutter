import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';

import 'attriax_web_app_info_loader.dart';
import 'attriax_web_environment_stub.dart';
import 'attriax_web_environment_stub.dart'
    if (dart.library.js_interop) 'attriax_web_environment_web.dart'
    as web_environment;

typedef AttriaxWebEnvironmentProvider =
    AttriaxWebEnvironmentSnapshot Function();
typedef AttriaxWebAppInfoLoaderFactory =
    AttriaxWebAppInfoLoader Function(List<AttriaxWebBaseUrlProvider> providers);

class AttriaxWebPlatform extends AttriaxPlatform {
  AttriaxWebPlatform({
    AttriaxWebEnvironmentProvider? environmentProvider,
    AttriaxWebAppInfoLoaderFactory? appInfoLoaderFactory,
  }) : _environmentProvider =
           environmentProvider ?? web_environment.currentAttriaxWebEnvironment,
       _appInfoLoaderFactory =
           appInfoLoaderFactory ??
           ((providers) =>
               AttriaxWebAppInfoLoader(baseUrlProviders: providers));

  final AttriaxWebEnvironmentProvider _environmentProvider;
  final AttriaxWebAppInfoLoaderFactory _appInfoLoaderFactory;

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async {
    final environment = _environmentProvider();
    final appInfo = await _appInfoLoaderFactory(<AttriaxWebBaseUrlProvider>[
      () => environment.assetBaseUrl,
      () => environment.documentBaseUrl,
      () => environment.locationBaseUrl,
    ]).load();

    return AttriaxNativeContext(
      metadata: <String, Object?>{
        'appVersion': ?appInfo?.version,
        'appBuildNumber': ?appInfo?.buildNumber,
        'packageName': ?appInfo?.packageName,
        'timezone': ?environment.timezone,
        'appName': ?environment.appName,
        'browserName': ?environment.browserName,
        'userAgent': ?environment.userAgent,
        'platform': ?environment.platform,
        'vendor': ?environment.vendor,
        'title': ?environment.title,
        'referrer': ?environment.referrer,
        'url': ?environment.locationBaseUrl,
      },
    );
  }
}

class AttriaxWebPlugin {
  static void registerWith(Object registrar) {
    if (AttriaxPlatform.instance is MethodChannelAttriax) {
      AttriaxPlatform.instance = AttriaxWebPlatform();
    }
  }
}
