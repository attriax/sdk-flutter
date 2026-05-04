import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('attriax');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'collectNativeContext forwards the method call and parses the payload',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        expect(methodCall.method, 'collectNativeContext');
        return <String, Object?>{
          'androidId': 'android-id-123',
          'advertisingId': 'advertising-id-456',
          'metadata': <String, Object?>{
            'source': 'android_native',
            'locale': 'en-US',
          },
        };
      });

      final context = await MethodChannelAttriax().collectNativeContext();

      expect(context.androidId, 'android-id-123');
      expect(context.advertisingId, 'advertising-id-456');
      expect(context.metadata['source'], 'android_native');
      expect(context.metadata['locale'], 'en-US');
    },
  );

  test(
    'collectInstallReferrer falls back to an empty payload when the plugin is missing',
    () async {
      final context = await MethodChannelAttriax().collectInstallReferrer();

      expect(context.installReferrer, isNull);
      expect(context.metadata, isEmpty);
    },
  );

  test(
    'consumePendingCrashReport forwards the method call and parses the payload',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        expect(methodCall.method, 'consumePendingCrashReport');
        return <String, Object?>{
          'source': 'android_uncaught_exception',
          'isFatal': true,
          'exceptionType': 'java.lang.IllegalStateException',
          'message': 'boom',
          'stackTrace': 'stack line',
          'occurredAt': '2026-05-04T10:00:00.000Z',
          'metadata': <String, Object?>{'threadName': 'main'},
        };
      });

      final report = await MethodChannelAttriax().consumePendingCrashReport();

      expect(report, isNotNull);
      expect(report!.source, 'android_uncaught_exception');
      expect(report.isFatal, isTrue);
      expect(report.exceptionType, 'java.lang.IllegalStateException');
      expect(report.metadata['threadName'], 'main');
      expect(report.occurredAt, DateTime.utc(2026, 5, 4, 10, 0, 0));
    },
  );
}
