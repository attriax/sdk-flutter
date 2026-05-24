// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shared runtime methods return Windows plugin payloads', (
    WidgetTester tester,
  ) async {
    final platform = AttriaxWindows();
    final nativeContext = await platform.collectNativeContext();
    final installReferrer = await platform.collectInstallReferrer();

    expect(nativeContext.metadata['source'], 'windows_native');
    expect(
      installReferrer.metadata['installReferrerStatus'],
      'unsupported_windows',
    );
  });
}
