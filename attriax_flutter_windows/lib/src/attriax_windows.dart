import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';

/// Windows implementation of [AttriaxPlatform].
class AttriaxWindows extends MethodChannelAttriax {
  AttriaxWindows() : super(logName: 'attriax.windows');

  static void registerWith() {
    AttriaxPlatform.instance = AttriaxWindows();
  }
}
