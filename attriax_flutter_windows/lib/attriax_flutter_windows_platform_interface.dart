import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'attriax_flutter_windows_method_channel.dart';

abstract class AttriaxFlutterWindowsPlatform extends PlatformInterface {
  /// Constructs a AttriaxFlutterWindowsPlatform.
  AttriaxFlutterWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AttriaxFlutterWindowsPlatform _instance =
      MethodChannelAttriaxFlutterWindows();

  /// The default instance of [AttriaxFlutterWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelAttriaxFlutterWindows].
  static AttriaxFlutterWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AttriaxFlutterWindowsPlatform] when
  /// they register themselves.
  static set instance(AttriaxFlutterWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
