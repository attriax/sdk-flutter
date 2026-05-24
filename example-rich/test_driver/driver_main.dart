import 'package:flutter_driver/driver_extension.dart';

import 'package:attriax_flutter_rich_example/main.dart' as app;

Future<void> main() async {
  enableFlutterDriverExtension();
  await app.main();
}
