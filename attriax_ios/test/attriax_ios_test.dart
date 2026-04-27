import 'package:attriax_ios/attriax_ios.dart';
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
    'collectNativeContext uses the expected method and parses metadata',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        expect(methodCall.method, 'collectNativeContext');
        return <String, Object?>{
          'metadata': <String, Object?>{
            'source': 'ios_native',
            'teamIdentifier': 'TEAM123',
          },
        };
      });

      final context = await AttriaxIos().collectNativeContext();

      expect(context.installReferrer, isNull);
      expect(context.metadata['source'], 'ios_native');
      expect(context.metadata['teamIdentifier'], 'TEAM123');
    },
  );

  test(
    'collectInstallReferrer returns an empty payload when the platform call fails',
    () async {
      messenger.setMockMethodCallHandler(channel, (methodCall) async {
        throw PlatformException(
          code: 'unavailable',
          message: 'native collector failed',
        );
      });

      final context = await AttriaxIos().collectInstallReferrer();

      expect(context.installReferrer, isNull);
      expect(context.metadata, isEmpty);
    },
  );
}
