// ignore_for_file: unnecessary_overrides

import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';

/// Windows implementation of [AttriaxPlatform].
class AttriaxWindows extends MethodChannelAttriax {
  AttriaxWindows() : super(logName: 'attriax.windows');

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) => super.collectNativeContext(collectAdvertisingId: collectAdvertisingId);

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() =>
      super.collectInstallReferrer();

  static void registerWith() {
    AttriaxPlatform.instance = AttriaxWindows();
  }
}
