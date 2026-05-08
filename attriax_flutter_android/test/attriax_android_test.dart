import 'package:attriax_flutter_android/attriax_flutter_android.dart';
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
    'collectInstallReferrer uses the expected method and parses the response',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        expect(methodCall.method, 'collectInstallReferrer');
        return <String, Object?>{
          'installReferrer': 'utm_source=test-suite',
          'metadata': <String, Object?>{'source': 'android_install_referrer'},
        };
      });

      final context = await AttriaxAndroid().collectInstallReferrer();

      expect(context.installReferrer, 'utm_source=test-suite');
      expect(context.metadata['source'], 'android_install_referrer');
    },
  );

  test(
    'collectInstallReferrer returns structured metadata when the platform call fails',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        throw PlatformException(
          code: 'unavailable',
          message: 'referrer lookup failed',
        );
      });

      final context = await AttriaxAndroid().collectInstallReferrer();

      expect(context.installReferrer, isNull);
      expect(context.metadata['installReferrerStatus'], 'platform_exception');
      expect(
        context.metadata['installReferrerError'],
        'referrer lookup failed',
      );
    },
  );

  test(
    'collectNativeContext returns an empty payload when the platform call fails',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        throw PlatformException(
          code: 'unavailable',
          message: 'native collector failed',
        );
      });

      final context = await AttriaxAndroid().collectNativeContext();

      expect(context.installReferrer, isNull);
      expect(context.androidId, isNull);
      expect(context.advertisingId, isNull);
      expect(context.metadata, isEmpty);
    },
  );
}
