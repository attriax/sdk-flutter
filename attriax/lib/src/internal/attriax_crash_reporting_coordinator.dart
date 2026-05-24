import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:attriax_flutter_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';

import 'attriax_api_models.dart';
import 'attriax_consent_manager.dart';
import 'attriax_context_manager.dart';
import 'attriax_preferences_store.dart';
import 'attriax_request_manager.dart';
import 'attriax_tracking_manager.dart';

typedef AttriaxCrashReportingRuntimeActiveProvider = bool Function();
typedef AttriaxCrashReportingDecisionProvider =
    AttriaxTrackingDecision Function();

class AttriaxCrashReportingCoordinator {
  AttriaxCrashReportingCoordinator({
    required AttriaxConfig config,
    required AttriaxClock clock,
    required AttriaxPlatform platform,
    required AttriaxContextManager contextManager,
    required AttriaxTrackingManager trackingManager,
    required AttriaxRequestManager requestManager,
    required AttriaxCrashStore preferencesStore,
    required AttriaxCrashReportingRuntimeActiveProvider isRuntimeActive,
    required AttriaxCrashReportingDecisionProvider analyticsTrackingDecision,
  }) : _config = config,
       _clock = clock,
       _platform = platform,
       _contextManager = contextManager,
       _trackingManager = trackingManager,
       _requestManager = requestManager,
       _preferencesStore = preferencesStore,
       _isRuntimeActive = isRuntimeActive,
       _analyticsTrackingDecision = analyticsTrackingDecision;

  final AttriaxConfig _config;
  final AttriaxClock _clock;
  final AttriaxPlatform _platform;
  final AttriaxContextManager _contextManager;
  final AttriaxTrackingManager _trackingManager;
  final AttriaxRequestManager _requestManager;
  final AttriaxCrashStore _preferencesStore;
  final AttriaxCrashReportingRuntimeActiveProvider _isRuntimeActive;
  final AttriaxCrashReportingDecisionProvider _analyticsTrackingDecision;

  FlutterExceptionHandler? _previousFlutterErrorHandler;
  FlutterExceptionHandler? _installedFlutterErrorHandler;
  bool Function(Object, StackTrace)? _previousPlatformErrorHandler;
  bool Function(Object, StackTrace)? _installedPlatformErrorHandler;

  Future<void> activate({required bool installHandlers}) async {
    await _contextManager.setAutomaticCrashReportingEnabled(
      enabled: installHandlers,
    );
    if (!installHandlers) {
      _restoreHandlers();
      return;
    }

    _installHandlers();
    await _capturePendingNativeCrashReport();
    await _replayPendingCrashReport();
  }

  Future<void> deactivate() async {
    _restoreHandlers();
    await _contextManager.setAutomaticCrashReportingEnabled(enabled: false);
  }

  void _installHandlers() {
    if (!_config.automaticCrashReportingEnabled) {
      return;
    }

    if (_installedFlutterErrorHandler == null) {
      _previousFlutterErrorHandler = FlutterError.onError;
      _installedFlutterErrorHandler = (details) {
        _previousFlutterErrorHandler?.call(details);
        final metadata = <String, Object?>{
          if (details.library != null) 'library': details.library,
          if (details.silent) 'silent': true,
        };
        unawaited(
          _recordAutomaticFrameworkError(
            details.exception,
            details.stack ?? StackTrace.current,
            reason: details.context?.toDescription(),
            metadata: metadata.isEmpty ? null : metadata,
          ),
        );
      };
      FlutterError.onError = _installedFlutterErrorHandler;
    }

    if (_installedPlatformErrorHandler == null) {
      _previousPlatformErrorHandler = ui.PlatformDispatcher.instance.onError;
      _installedPlatformErrorHandler = (error, stackTrace) {
        unawaited(
          _persistFatalCrashForRetry(
            error,
            stackTrace,
            source: 'platform_dispatcher',
            reason: 'Unhandled root isolate error',
          ),
        );

        final previous = _previousPlatformErrorHandler;
        if (previous != null) {
          return previous(error, stackTrace);
        }

        return false;
      };
      ui.PlatformDispatcher.instance.onError = _installedPlatformErrorHandler;
    }
  }

  void _restoreHandlers() {
    if (identical(FlutterError.onError, _installedFlutterErrorHandler)) {
      FlutterError.onError = _previousFlutterErrorHandler;
    }
    if (identical(
      ui.PlatformDispatcher.instance.onError,
      _installedPlatformErrorHandler,
    )) {
      ui.PlatformDispatcher.instance.onError = _previousPlatformErrorHandler;
    }

    _installedFlutterErrorHandler = null;
    _previousFlutterErrorHandler = null;
    _installedPlatformErrorHandler = null;
    _previousPlatformErrorHandler = null;
  }

  Future<void> _recordAutomaticFrameworkError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, Object?>? metadata,
  }) async {
    if (!_isRuntimeActive()) {
      return;
    }

    await _trackingManager.recordError(
      error,
      stackTrace,
      source: 'flutter_error',
      reason: reason,
      metadata: metadata,
    );
  }

  Future<void> _persistFatalCrashForRetry(
    Object error,
    StackTrace stackTrace, {
    required String source,
    String? reason,
    Map<String, Object?>? metadata,
  }) async {
    if (!_isRuntimeActive()) {
      return;
    }

    await _storePendingCrashReport(
      _buildCrashRequest(
        clientOccurredAt: _clock.now(),
        source: source,
        isFatal: true,
        exceptionType: error.runtimeType.toString(),
        message: error.toString(),
        metadata: metadata,
        reason: reason,
        stackTrace: stackTrace.toString(),
      ),
    );
  }

  Future<void> _capturePendingNativeCrashReport() async {
    final nativeReport = await _platform.consumePendingCrashReport();
    if (nativeReport == null) {
      return;
    }

    await _storePendingCrashReport(
      _buildCrashRequest(
        clientOccurredAt: nativeReport.occurredAt ?? _clock.now(),
        source: nativeReport.source,
        isFatal: nativeReport.isFatal,
        exceptionType: nativeReport.exceptionType,
        message: nativeReport.message,
        metadata: nativeReport.metadata,
        reason: nativeReport.reason,
        stackTrace: nativeReport.stackTrace,
      ),
    );
  }

  Future<void> _replayPendingCrashReport() async {
    final payload = await _readPendingCrashReport();
    if (payload == null) {
      return;
    }

    await _requestManager.enqueue(
      AttriaxTrackCrashRequest(payload),
      onSuccess: (_) {
        unawaited(_preferencesStore.writePendingCrashReportPayload(null));
      },
    );
  }

  AttriaxTrackCrashRequest _buildCrashRequest({
    required DateTime clientOccurredAt,
    required String source,
    required bool isFatal,
    required String exceptionType,
    required String message,
    required String stackTrace,
    String? reason,
    Map<String, Object?>? metadata,
  }) {
    final decision = _analyticsTrackingDecision();

    return attriaxBuildTrackCrashRequest(
      appToken: _config.appToken,
      clientOccurredAt: clientOccurredAt,
      context: _contextManager.requiredSnapshot,
      deviceId: decision.attachDeviceIdentity
          ? _contextManager.requiredDeviceId
          : null,
      deviceIdSource: decision.attachDeviceIdentity
          ? _contextManager.requireDeviceIdSource()
          : null,
      source: source,
      isFatal: isFatal,
      exceptionType: exceptionType,
      message: message,
      metadata: metadata,
      reason: reason,
      stackTrace: stackTrace,
    );
  }

  Future<void> _storePendingCrashReport(AttriaxTrackCrashRequest request) =>
      _preferencesStore.writePendingCrashReportPayload(
        jsonEncode(request.payload.toJson()),
      );

  Future<AttriaxCrashReportPayload?> _readPendingCrashReport() async {
    final raw = await _preferencesStore.readPendingCrashReportPayload();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await _preferencesStore.writePendingCrashReportPayload(null);
        return null;
      }

      return AttriaxCrashReportPayload.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value as Object?)),
      );
    } catch (_) {
      await _preferencesStore.writePendingCrashReportPayload(null);
      return null;
    }
  }
}
