import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';
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
        expect(methodCall.arguments, <String, Object?>{
          'collectAdvertisingId': false,
        });
        return <String, Object?>{
          'androidId': 'android-id-123',
          'advertisingId': 'advertising-id-456',
          'metadata': <String, Object?>{
            'source': 'android_native',
            'locale': 'en-US',
          },
        };
      });

      final context = await MethodChannelAttriax().collectNativeContext(
        collectAdvertisingId: false,
      );

      expect(context.androidId, 'android-id-123');
      expect(context.advertisingId, 'advertising-id-456');
      expect(context.metadata['source'], 'android_native');
      expect(context.metadata['locale'], 'en-US');
    },
  );

  test('setAutomaticCrashReportingEnabled forwards the method call', () async {
    messenger.setMockMethodCallHandler(channel, (methodCall) async {
      expect(methodCall.method, 'setAutomaticCrashReportingEnabled');
      expect(methodCall.arguments, <String, Object?>{'enabled': false});
      return null;
    });

    await MethodChannelAttriax().setAutomaticCrashReportingEnabled(
      enabled: false,
    );
  });

  test('requestTrackingAuthorization parses authorized status', () async {
    messenger.setMockMethodCallHandler(channel, (methodCall) async {
      expect(methodCall.method, 'requestTrackingAuthorization');
      return 'authorized';
    });

    final status = await MethodChannelAttriax().requestTrackingAuthorization();

    expect(status, AttriaxTrackingAuthorizationStatus.authorized);
  });

  test('requestTrackingAuthorization has no implicit timeout', () async {
    messenger.setMockMethodCallHandler(channel, (methodCall) async {
      expect(methodCall.method, 'requestTrackingAuthorization');
      await Future<void>.delayed(const Duration(milliseconds: 25));
      return 'authorized';
    });

    final status = await MethodChannelAttriax().requestTrackingAuthorization();

    expect(status, AttriaxTrackingAuthorizationStatus.authorized);
  });

  test('requestTrackingAuthorization reports timeout', () async {
    messenger.setMockMethodCallHandler(channel, (methodCall) async {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      return 'authorized';
    });

    final status = await MethodChannelAttriax().requestTrackingAuthorization(
      timeout: const Duration(milliseconds: 1),
    );

    expect(status, AttriaxTrackingAuthorizationStatus.timedOut);
  });

  test('getTrackingAuthorizationStatus parses the payload', () async {
    messenger.setMockMethodCallHandler(channel, (methodCall) async {
      expect(methodCall.method, 'getTrackingAuthorizationStatus');
      return 'not_determined';
    });

    final status = await MethodChannelAttriax()
        .getTrackingAuthorizationStatus();

    expect(status, AttriaxTrackingAuthorizationStatus.notDetermined);
  });

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
      expect(report.occurredAt, DateTime.utc(2026, 5, 4, 10, 0));
    },
  );

  test(
    'openBrowserUrl forwards the method call and normalizes unknown mode',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        expect(methodCall.method, 'openBrowserUrl');
        expect(methodCall.arguments, <String, Object?>{
          'url': 'https://example.com/browser',
          'openMode': 'in_app',
        });
        return true;
      });

      final opened = await MethodChannelAttriax().openBrowserUrl(
        uri: Uri.parse('https://example.com/browser'),
        openMode: AttriaxResolvedUrlOpenMode.unknown,
      );

      expect(opened, isTrue);
    },
  );
}
