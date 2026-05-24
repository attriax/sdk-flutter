import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';

import 'attriax_web_platform.dart';

AttriaxWebPlatform? _registeredWebPlatform;

void ensureAttriaxDefaultPlatformRegistered() {
  if (AttriaxPlatform.instance is MethodChannelAttriax) {
    AttriaxPlatform.instance = _registeredWebPlatform ??= AttriaxWebPlatform();
  }
}
