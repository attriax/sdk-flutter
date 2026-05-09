import 'package:flutter_test/flutter_test.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows_platform_interface.dart';
import 'package:attriax_flutter_windows/attriax_flutter_windows_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAttriaxFlutterWindowsPlatform
    with MockPlatformInterfaceMixin
    implements AttriaxFlutterWindowsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AttriaxFlutterWindowsPlatform initialPlatform =
      AttriaxFlutterWindowsPlatform.instance;

  test('$MethodChannelAttriaxFlutterWindows is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAttriaxFlutterWindows>());
  });

  test('getPlatformVersion', () async {
    AttriaxFlutterWindows attriaxFlutterWindowsPlugin = AttriaxFlutterWindows();
    MockAttriaxFlutterWindowsPlatform fakePlatform =
        MockAttriaxFlutterWindowsPlatform();
    AttriaxFlutterWindowsPlatform.instance = fakePlatform;

    expect(await attriaxFlutterWindowsPlugin.getPlatformVersion(), '42');
  });
}
