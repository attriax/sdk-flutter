import 'package:flutter_test/flutter_test.dart';

import 'package:example_gdpr/main.dart';

void main() {
  testWidgets('renders manual GDPR controls before initialization', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleGdprApp());

    expect(find.text('Attriax GDPR Example'), findsWidgets);
    expect(find.text('Init SDK'), findsOneWidget);
    expect(find.text('Check local consent'), findsOneWidget);
    expect(find.text('Apply consent'), findsOneWidget);
    expect(find.text('Request data erasure'), findsOneWidget);
    expect(find.text('Record demo event'), findsOneWidget);
  });
}
