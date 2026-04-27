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
}
