import 'dart:async';
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
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'collectNativeContext',
        <String, Object?>{'collectAdvertisingId': collectAdvertisingId},
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

  @override
  Future<void> setAutomaticCrashReportingEnabled({
    required bool enabled,
  }) async {
    try {
      await _channel.invokeMethod<Object?>(
        'setAutomaticCrashReportingEnabled',
        <String, Object?>{'enabled': enabled},
      );
    } on MissingPluginException catch (error, stackTrace) {
      _logException('setAutomaticCrashReportingEnabled', error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _logException('setAutomaticCrashReportingEnabled', error, stackTrace);
    }
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'getTrackingAuthorizationStatus',
      );
      return _trackingAuthorizationStatusFromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('getTrackingAuthorizationStatus', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.notSupported;
    } on PlatformException catch (error, stackTrace) {
      _logException('getTrackingAuthorizationStatus', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.unknown;
    }
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    try {
      final invocation = _channel.invokeMethod<Object?>(
        'requestTrackingAuthorization',
      );
      final result = timeout == null
          ? await invocation
          : await invocation.timeout(timeout);
      return _trackingAuthorizationStatusFromPayload(result);
    } on TimeoutException {
      return AttriaxTrackingAuthorizationStatus.timedOut;
    } on MissingPluginException catch (error, stackTrace) {
      _logException('requestTrackingAuthorization', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.notSupported;
    } on PlatformException catch (error, stackTrace) {
      _logException('requestTrackingAuthorization', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.unknown;
    }
  }

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    try {
      final result = await _channel
          .invokeMethod<Object?>('updateSkanConversionValue', <String, Object?>{
            'fineValue': fineValue,
            if (coarseValue != null) 'coarseValue': coarseValue.name,
            'lockWindow': lockWindow,
          });
      return AttriaxSkanUpdateResult.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('updateSkanConversionValue', error, stackTrace);
      return const AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.notSupported,
        message:
            'SKAdNetwork conversion updates are not supported on this platform.',
      );
    } on PlatformException catch (error, stackTrace) {
      _logException('updateSkanConversionValue', error, stackTrace);
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.error,
        message: error.message,
      );
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
      '$runtimeType.$method failed: ${error.runtimeType}',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  AttriaxTrackingAuthorizationStatus _trackingAuthorizationStatusFromPayload(
    Object? payload,
  ) => switch (payload) {
    'not_supported' => AttriaxTrackingAuthorizationStatus.notSupported,
    'not_determined' => AttriaxTrackingAuthorizationStatus.notDetermined,
    'restricted' => AttriaxTrackingAuthorizationStatus.restricted,
    'denied' => AttriaxTrackingAuthorizationStatus.denied,
    'authorized' => AttriaxTrackingAuthorizationStatus.authorized,
    'timed_out' => AttriaxTrackingAuthorizationStatus.timedOut,
    _ => AttriaxTrackingAuthorizationStatus.unknown,
  };
}
