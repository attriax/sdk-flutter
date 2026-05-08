import 'package:attriax_flutter_platform_interface/attriax_flutter_platform_interface.dart';

/// iOS implementation of [AttriaxPlatform].
class AttriaxIos extends MethodChannelAttriax {
  AttriaxIos() : super(logName: 'attriax.ios');

  static void registerWith() {
    AttriaxPlatform.instance = AttriaxIos();
  }
}
