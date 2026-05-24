import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerWith installs AttriaxWindows as the active platform', () {
    final originalPlatform = AttriaxPlatform.instance;
    addTearDown(() {
      AttriaxPlatform.instance = originalPlatform;
    });

    AttriaxWindows.registerWith();

    expect(AttriaxPlatform.instance, isA<AttriaxWindows>());
  });
}
