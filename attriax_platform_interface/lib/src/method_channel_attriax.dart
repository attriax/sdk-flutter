import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'attriax_platform_interface.dart';
import 'types.dart';

/// An implementation of [AttriaxPlatform] that uses method channels.
class MethodChannelAttriax extends AttriaxPlatform {
  final MethodChannel _channel = const MethodChannel('attriax');

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
      'MethodChannelAttriax.$method failed: ${error.runtimeType}',
      name: 'attriax.platform_interface',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
