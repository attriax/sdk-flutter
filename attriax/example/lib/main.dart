import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import 'example_app_configuration.dart';
import 'integration_example_app.dart';

export 'integration_example_app.dart'
    show
        AttriaxIntegrationExampleApp,
        AttriaxIntegrationExampleHome,
        AttriaxIntegrationExampleSetupPage;

// Dev-stack defaults for the web live test: a plain `flutter build web` /
// `flutter run -d chrome` points the sdk-js engine at the local dev API so the
// browser exercises real `POST /api/sdk/v1/open` + `/sessions`. Native builds
// keep the public API + example token. Override either with
// `--dart-define=ATTRIAX_API_BASE_URL=…` / `--dart-define=ATTRIAX_PROJECT_TOKEN=…`.
const String _devWebApiBaseUrl = 'http://localhost:33000';
const String _devWebProjectToken = 'ax_4961d1f22e274281919b1b021ec2eb48';

const String _resolvedApiBaseUrl = String.fromEnvironment(
  'ATTRIAX_API_BASE_URL',
  defaultValue: kIsWeb ? _devWebApiBaseUrl : 'https://api.attriax.com',
);
const String _resolvedProjectToken = String.fromEnvironment(
  'ATTRIAX_PROJECT_TOKEN',
  defaultValue: kIsWeb ? _devWebProjectToken : exampleProjectToken,
);

final Attriax _exampleSdk = Attriax(
  config: const AttriaxConfig(
    projectToken: _resolvedProjectToken,
    apiBaseUrl: _resolvedApiBaseUrl,
    gdprEnabled: true,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? bootstrapError;
  if (!isExampleProjectConfigured) {
    bootstrapError =
        'Set a real Attriax project token in lib/example_app_configuration.dart before running this example.';
  } else {
    try {
      await _exampleSdk.init();
    } catch (error) {
      bootstrapError = 'Attriax init failed: $error';
    }
  }

  runApp(
    AttriaxIntegrationExampleApp(
      sdk: _exampleSdk,
      ownsSdk: true,
      bootstrapError: bootstrapError,
    ),
  );
}
