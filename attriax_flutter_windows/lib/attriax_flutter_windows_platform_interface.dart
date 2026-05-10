import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'attriax_flutter_windows_method_channel.dart';

/// Platform interface for the Attriax Windows Flutter plugin.
abstract class AttriaxFlutterWindowsPlatform extends PlatformInterface {
  /// Creates the base platform interface implementation.
  AttriaxFlutterWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AttriaxFlutterWindowsPlatform _instance =
      MethodChannelAttriaxFlutterWindows();

  /// Returns the active platform implementation.
  static AttriaxFlutterWindowsPlatform get instance => _instance;

  /// Replaces the active platform implementation after token verification.
  static set instance(AttriaxFlutterWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the Windows platform version reported by the native plugin.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
