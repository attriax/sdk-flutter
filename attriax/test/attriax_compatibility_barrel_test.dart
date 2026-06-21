import 'package:attriax_flutter/attriax.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compatibility barrel exports the public Attriax API', () {
    expect(Attriax, isNotNull);
    expect(attriaxSdkPackageVersion, '0.5.0');
  });
}
