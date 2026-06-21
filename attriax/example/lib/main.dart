import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/widgets.dart';

import 'example_app_configuration.dart';
import 'integration_example_app.dart';

export 'integration_example_app.dart'
    show
        AttriaxIntegrationExampleApp,
        AttriaxIntegrationExampleHome,
        AttriaxIntegrationExampleSetupPage;

final Attriax _exampleSdk = Attriax(
  config: AttriaxConfig(projectToken: exampleProjectToken, gdprEnabled: true),
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
