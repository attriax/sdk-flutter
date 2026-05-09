import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'attriax_flutter_windows_platform_interface.dart';

/// An implementation of [AttriaxFlutterWindowsPlatform] that uses method channels.
class MethodChannelAttriaxFlutterWindows extends AttriaxFlutterWindowsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('attriax_flutter_windows');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
