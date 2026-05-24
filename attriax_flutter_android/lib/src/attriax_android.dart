import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:flutter/services.dart';

/// Android implementation of [AttriaxPlatform].
class AttriaxAndroid extends MethodChannelAttriax {
  AttriaxAndroid() : super(logName: 'attriax.android');

  static void registerWith() {
    AttriaxPlatform.instance = AttriaxAndroid();
  }

  @override
  AttriaxInstallReferrerContext missingPluginInstallReferrerContext(
    MissingPluginException error,
  ) => AttriaxInstallReferrerContext(
    metadata: {
      'installReferrerStatus': 'missing_plugin',
      'installReferrerError': error.message ?? error.toString(),
    },
  );

  @override
  AttriaxInstallReferrerContext platformExceptionInstallReferrerContext(
    PlatformException error,
  ) => AttriaxInstallReferrerContext(
    metadata: {
      'installReferrerStatus': 'platform_exception',
      'installReferrerError': error.message ?? error.code,
    },
  );
}
