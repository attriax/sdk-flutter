import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'attriax_platform_interface.dart';
import 'types.dart';

/// An implementation of [AttriaxPlatform] that uses method channels.
class MethodChannelAttriax extends AttriaxPlatform {
  MethodChannelAttriax({
    MethodChannel? channel,
    String logName = 'attriax.platform_interface',
  }) : _channel = channel ?? const MethodChannel('attriax'),
       _logName = logName;

  final MethodChannel _channel;
  final String _logName;

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
      return missingPluginInstallReferrerContext(error);
    } on PlatformException catch (error, stackTrace) {
      _logException('collectInstallReferrer', error, stackTrace);
      return platformExceptionInstallReferrerContext(error);
    }
  }

  @override
  Future<AttriaxPendingCrashReport?> consumePendingCrashReport() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'consumePendingCrashReport',
      );
      if (result == null) {
        return null;
      }

      return AttriaxPendingCrashReport.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('consumePendingCrashReport', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('consumePendingCrashReport', error, stackTrace);
      return null;
    } on FormatException catch (error, stackTrace) {
      _logException('consumePendingCrashReport', error, stackTrace);
      return null;
    }
  }

  AttriaxInstallReferrerContext missingPluginInstallReferrerContext(
    MissingPluginException error,
  ) => const AttriaxInstallReferrerContext();

  AttriaxInstallReferrerContext platformExceptionInstallReferrerContext(
    PlatformException error,
  ) => const AttriaxInstallReferrerContext();

  void _logException(String method, Object error, StackTrace stackTrace) {
    developer.log(
      '${runtimeType}.$method failed: ${error.runtimeType}',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
