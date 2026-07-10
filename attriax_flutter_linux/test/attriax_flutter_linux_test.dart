import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_linux/attriax_flutter_linux.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registerWith installs AttriaxLinux as the active platform', () {
    final originalPlatform = AttriaxPlatform.instance;
    addTearDown(() {
      AttriaxPlatform.instance = originalPlatform;
    });

    AttriaxLinux.registerWith();

    expect(AttriaxPlatform.instance, isA<AttriaxLinux>());
  });
}
