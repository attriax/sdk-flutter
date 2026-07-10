// Basic widget smoke test for the Attriax Windows example app.
//
// The app's engine bootstrap loads the native `attriax_core.dll`, which is not
// present under `flutter test` (it is bundled next to the built executable), so
// initialization degrades to a benign "Init failed" status without throwing.
// This test only verifies that the UI scaffold renders.

import 'package:flutter_test/flutter_test.dart';

import 'package:attriax_flutter_windows_example/main.dart';

void main() {
  testWidgets('renders the example scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Attriax Windows Example'), findsOneWidget);
    expect(find.text('Send test event'), findsOneWidget);
  });
}
