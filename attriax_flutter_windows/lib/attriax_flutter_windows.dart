import 'attriax_flutter_windows_platform_interface.dart';

/// Public entry point for the Attriax Windows Flutter plugin.
class AttriaxFlutterWindows {
  /// Returns the current Windows platform version reported by the native plugin.
  Future<String?> getPlatformVersion() {
    return AttriaxFlutterWindowsPlatform.instance.getPlatformVersion();
  }
}
