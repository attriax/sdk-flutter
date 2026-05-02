import 'dart:async';

import 'package:attriax_platform_interface/attriax_platform_interface.dart';

import 'attriax_api_models.dart';
import 'attriax_event_hub.dart';
import 'attriax_logger.dart';
import 'attriax_synchronizer.dart';

/// Handles incoming deep-link events from Attriax's platform bridge and manual
/// deep-link resolution requests, delegating resolution to the Attriax backend
/// and emitting results through the runtime event hub.
class AttriaxDeepLinkResolver {
  AttriaxDeepLinkResolver({
    required this.config,
    required this.deviceId,
    required this.deviceIdSource,
    required this.isFirstLaunch,
    required this.context,
    required AttriaxSynchronizer synchronizer,
    required AttriaxEventHub eventHub,
    required AttriaxLogger logger,
  }) : _synchronizer = synchronizer,
       _eventHub = eventHub,
       _logger = logger;

  final AttriaxConfig config;
  final String deviceId;
  final String deviceIdSource;
  final bool isFirstLaunch;
  final AttriaxContextSnapshot context;

  final AttriaxSynchronizer _synchronizer;
  final AttriaxEventHub _eventHub;
  final AttriaxLogger _logger;

  // ---------- incoming ------------------------------------------------------ //

  /// Called by the deep-link listener for every deduplicated deep link.
  Future<void> handleIncoming(Uri uri, {required bool isInitialLink}) async {
    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: uri,
      linkPath: _extractLinkPathFromUri(uri),
      isFirstLaunch: isFirstLaunch,
      isInitialLink: isInitialLink,
      occurredAt: DateTime.now().toUtc(),
    );

    _eventHub.emitPendingDeepLink(rawEvent);
    _logger.verbose(
      'Received deep link ${rawEvent.linkPath ?? rawEvent.uri.toString()}.',
    );

    await _synchronizer.enqueue(
      attriaxBuildResolveDeepLinkRequest(
        appToken: config.appToken,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        platform: context.platform,
        source: 'attriax_sdk',
        isFirstLaunch: isFirstLaunch,
        rawUrl: uri.toString(),
        metadata: <String, Object?>{
          'isInitialLink': isInitialLink,
          'queryParameters': uri.queryParametersAll,
        },
      ),
      onSuccess: (response) {
        if (response is! AttriaxResolveDeepLinkApiResponse) {
          _logger.error('Unexpected response type for deep-link resolution.');
          return;
        }

        final event = _buildResolution(
          response.result,
          rawEvent: rawEvent,
          isDeferred: false,
        );
        if (event != null) {
          _eventHub.resolvePendingDeepLink(
            rawEvent: rawEvent,
            resolution: event,
          );
          return;
        }

        _eventHub.failPendingDeepLink(
          rawEvent: rawEvent,
          failure: _buildFailure(response.result, rawEvent: rawEvent),
        );
      },
      onError: (error, stackTrace) {
        _logger.error(
          'Deep-link resolution request failed.',
          error: error,
          stackTrace: stackTrace,
        );
        _eventHub.failPendingDeepLink(
          rawEvent: rawEvent,
          failure: AttriaxDeepLinkResolutionFailure(
            reason: error.toString(),
            rawEvent: rawEvent,
            isFirstLaunch: rawEvent.isFirstLaunch,
            occurredAt: DateTime.now().toUtc(),
          ),
        );
      },
    );
  }

  // ---------- manual -------------------------------------------------------- //

  /// Records a deep-link resolution manually, emitting the same resolution
  /// signals as automatic handling. Returns the resolution on success, `null` on
  /// failure.
  Future<AttriaxDeepLinkResolution?> recordManualConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    if (uri == null && (linkPath == null || linkPath.trim().isEmpty)) {
      throw ArgumentError('Either uri or linkPath must be provided.');
    }

    final normalizedLinkPath = normalizeLinkPath(linkPath);
    final effectiveUri =
        uri ??
        Uri(path: normalizedLinkPath == null ? '/' : '/$normalizedLinkPath');
    final rawEvent = AttriaxRawDeepLinkEvent(
      uri: effectiveUri,
      linkPath: _extractLinkPathFromUri(effectiveUri) ?? normalizedLinkPath,
      isFirstLaunch: isFirstLaunch,
      isInitialLink: false,
      occurredAt: DateTime.now().toUtc(),
    );
    final completer = Completer<AttriaxDeepLinkResolution?>();
    _eventHub.emitPendingDeepLink(rawEvent);

    await _synchronizer.enqueue(
      attriaxBuildResolveDeepLinkRequest(
        appToken: config.appToken,
        deviceId: deviceId,
        deviceIdSource: deviceIdSource,
        platform: context.platform,
        source: source,
        isFirstLaunch: isFirstLaunch,
        rawUrl: uri?.toString(),
        linkPath: normalizedLinkPath,
        metadata: metadata,
      ),
      onSuccess: (response) {
        if (response is! AttriaxResolveDeepLinkApiResponse) {
          _logger.error('Unexpected response type for deep-link resolution.');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return;
        }

        final event = _buildResolution(
          response.result,
          rawEvent: rawEvent,
          isDeferred: false,
        );
        if (event != null) {
          _eventHub.resolvePendingDeepLink(
            rawEvent: rawEvent,
            resolution: event,
          );
          if (!completer.isCompleted) {
            completer.complete(event);
          }
          return;
        }

        _eventHub.failPendingDeepLink(
          rawEvent: rawEvent,
          failure: _buildFailure(response.result, rawEvent: rawEvent),
        );
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
      onError: (error, stackTrace) {
        _logger.error(
          'Manual deep-link resolution failed.',
          error: error,
          stackTrace: stackTrace,
        );
        _eventHub.failPendingDeepLink(
          rawEvent: rawEvent,
          failure: AttriaxDeepLinkResolutionFailure(
            reason: error.toString(),
            rawEvent: rawEvent,
            isFirstLaunch: isFirstLaunch,
            occurredAt: DateTime.now().toUtc(),
          ),
        );
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    );

    return completer.future;
  }

  // ---------- helpers ------------------------------------------------------- //

  /// Strips leading/trailing slashes and whitespace; returns `null` for blank
  /// inputs.
  String? normalizeLinkPath(String? path) {
    if (path == null) {
      return null;
    }
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final normalized = trimmed
        .replaceFirst(RegExp('^/+'), '')
        .replaceFirst(RegExp(r'/+$'), '');
    return normalized.isEmpty ? null : normalized;
  }

  AttriaxDeepLinkResolution? _buildResolution(
    AttriaxDeepLinkResolutionResult result, {
    required AttriaxRawDeepLinkEvent? rawEvent,
    required bool isDeferred,
  }) {
    final deepLink = result.deepLink;
    if (!result.matched || deepLink == null) {
      return null;
    }

    return AttriaxDeepLinkResolution(
      deepLink: deepLink,
      rawEvent: rawEvent,
      isFirstLaunch: result.isFirstLaunch,
      isDeferred: isDeferred,
      consumedAt: result.consumedAt,
      occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
    );
  }

  AttriaxDeepLinkResolutionFailure _buildFailure(
    AttriaxDeepLinkResolutionResult result, {
    required AttriaxRawDeepLinkEvent? rawEvent,
  }) => AttriaxDeepLinkResolutionFailure(
    reason: result.reason ?? result.status.name,
    rawEvent: rawEvent,
    isFirstLaunch: result.isFirstLaunch,
    status: result.status,
    requestVersion: result.requestVersion,
    acceptedAt: result.acceptedAt,
    occurredAt: result.acceptedAt ?? DateTime.now().toUtc(),
  );

  String? _extractLinkPathFromUri(Uri uri) {
    final candidate = uri.path.isNotEmpty && uri.path != '/'
        ? uri.path
        : uri.host;
    return normalizeLinkPath(candidate);
  }
}
