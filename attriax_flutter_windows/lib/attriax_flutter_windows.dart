import 'attriax_flutter_windows_platform_interface.dart';

class AttriaxFlutterWindows {
  Future<String?> getPlatformVersion() {
    return AttriaxFlutterWindowsPlatform.instance.getPlatformVersion();
  }
}
