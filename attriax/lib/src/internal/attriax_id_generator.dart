import 'dart:math';

/// Generates a random UUID v4-like identifier used for device IDs and
/// queued request IDs.
String attriaxGenerateId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  final buffer = StringBuffer();
  for (var i = 0; i < bytes.length; i++) {
    buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    if (i == 3 || i == 5 || i == 7 || i == 9) {
      buffer.write('-');
    }
  }
  return buffer.toString();
}
