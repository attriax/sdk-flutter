import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'attriax_flutter_windows_platform_interface.dart';

/// Method-channel implementation of the Attriax Windows plugin platform API.
class MethodChannelAttriaxFlutterWindows extends AttriaxFlutterWindowsPlatform {
  /// Method channel used to interact with the native Windows plugin.
  @visibleForTesting
  final methodChannel = const MethodChannel('attriax_flutter_windows');

  @override
  /// Returns the Windows platform version from the native plugin.
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
