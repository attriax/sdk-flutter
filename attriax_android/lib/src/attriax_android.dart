import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:attriax_platform_interface/attriax_platform_interface.dart';

/// Android implementation of [AttriaxPlatform].
class AttriaxAndroid extends AttriaxPlatform {
  static const _channel = MethodChannel('attriax');

  static void registerWith() {
    AttriaxPlatform.instance = AttriaxAndroid();
  }

  @override
  Future<AttriaxNativeContext> collectNativeContext() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'collectNativeContext',
      );
      return AttriaxNativeContext.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('collectNativeContext', error, stackTrace);
      return const AttriaxNativeContext();
    } on PlatformException catch (error, stackTrace) {
      _logException('collectNativeContext', error, stackTrace);
      return const AttriaxNativeContext();
    }
  }

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'collectInstallReferrer',
      );
      return AttriaxInstallReferrerContext.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('collectInstallReferrer', error, stackTrace);
      return const AttriaxInstallReferrerContext();
    } on PlatformException catch (error, stackTrace) {
      _logException('collectInstallReferrer', error, stackTrace);
      return const AttriaxInstallReferrerContext();
    }
  }

  void _logException(String method, Object error, StackTrace stackTrace) {
    developer.log(
      'AttriaxAndroid.$method failed: ${error.runtimeType}',
      name: 'attriax.android',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
