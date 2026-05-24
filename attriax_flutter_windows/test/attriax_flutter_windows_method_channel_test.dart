import 'package:flutter/services.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final AttriaxPlatform platform = AttriaxWindows();
  const channel = MethodChannel('attriax');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'collectNativeContext':
              return <String, Object?>{
                'metadata': <String, Object?>{'source': 'windows_native'},
              };
            case 'collectInstallReferrer':
              return <String, Object?>{
                'metadata': <String, Object?>{
                  'installReferrerStatus': 'unsupported_windows',
                },
              };
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('collectNativeContext uses the shared attriax channel', () async {
    final context = await platform.collectNativeContext();

    expect(context.metadata['source'], 'windows_native');
  });

  test('collectInstallReferrer uses the shared attriax channel', () async {
    final context = await platform.collectInstallReferrer();

    expect(context.metadata['installReferrerStatus'], 'unsupported_windows');
  });
}
