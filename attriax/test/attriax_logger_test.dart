import 'package:attriax_flutter/src/internal/attriax_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> lines;
  late DebugPrintCallback originalDebugPrint;

  setUp(() {
    lines = <String>[];
    originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        lines.add(message);
      }
    };
  });

  tearDown(() {
    debugPrint = originalDebugPrint;
  });

  test('emits only the concise line and no detail when debug logs are off', () {
    AttriaxLogger(enableDebugLogs: false).warning(
      'request failed',
      error: StateError('HTTP 500. Response body: secret-token'),
    );

    expect(lines, <String>['[Attriax][WARNING] request failed']);
    expect(
      lines.any((line) => line.contains('secret-token')),
      isFalse,
      reason: 'response-body detail must not leak when debug logs are off',
    );
  });

  test('attaches error detail when debug logs are enabled', () {
    AttriaxLogger(
      enableDebugLogs: true,
    ).error('request failed', error: StateError('boom'));

    expect(lines, contains('[Attriax][ERROR] request failed'));
    expect(lines.any((line) => line.contains('boom')), isTrue);
  });

  test('verbose is silent when debug logs are off', () {
    AttriaxLogger(enableDebugLogs: false).verbose('chatty');
    expect(lines, isEmpty);
  });
}
