import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/widgets.dart';

import 'example_app/example_app_formatters.dart';
import 'example_app/example_app_shell.dart';
import 'example_app_configuration.dart';

export 'example_app/example_app_shell.dart' show AttriaxPackageExampleApp;

final Attriax _exampleSdk = Attriax(
  config: AttriaxConfig(appToken: exampleAppToken),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? bootstrapError;
  if (!isExampleAppConfigured) {
    bootstrapError =
        'Set a real Attriax app token in lib/example_app_configuration.dart before running this example.';
  } else {
    try {
      await _exampleSdk.init();
    } catch (error) {
      bootstrapError = 'Attriax init failed: ${formatExampleError(error)}';
    }
  }

  runApp(
    AttriaxPackageExampleApp(
      sdk: _exampleSdk,
      ownsSdk: true,
      bootstrapError: bootstrapError,
    ),
  );
}
