// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests. Here
// that means the real `attriax_core.dll` C-ABI engine is exercised end-to-end.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:attriax_flutter_platform_interface/attriax_platform_types.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initializes the native engine and reports a device id', (
    WidgetTester tester,
  ) async {
    const config = AttriaxConfig(
      projectToken: 'ax_4961d1f22e274281919b1b021ec2eb48',
      apiBaseUrl: 'http://localhost:33000',
      appVersion: '1.0.0',
      appPackageName: 'com.attriax.example.windows',
      enableDebugLogs: true,
    );

    final platform = AttriaxWindows();
    await platform.initialize(config);
    addTearDown(platform.dispose);

    expect(await platform.getIsInitialized(), isTrue);
    expect(await platform.getDeviceId(), isNotNull);

    await platform.recordEvent(
      'integration_test_event',
      flushImmediately: true,
    );
  });
}
