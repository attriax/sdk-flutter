import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'attriax_api_models.dart';
import 'attriax_app_open_monitor.dart';
import 'attriax_generated_transport.dart';
import 'attriax_logger.dart';
import 'attriax_queue.dart';

typedef AttriaxSuccessHandler = void Function(AttriaxApiResponse response);
typedef AttriaxErrorHandler =
    void Function(Object error, StackTrace? stackTrace);

const int _attriaxMaxRetryAttempts = 8;
const Duration _attriaxMaxRetryAge = Duration(days: 7);

enum _DispatchFailureAction { retry, drop }

class _BatchDispatchResult {
  const _BatchDispatchResult({
    required this.remaining,
    required this.shouldStop,
  });

  const _BatchDispatchResult.success()
    : remaining = const <AttriaxQueuedRequest>[],
      shouldStop = false;

  const _BatchDispatchResult.retry(List<AttriaxQueuedRequest> requests)
    : remaining = requests,
      shouldStop = true;

  final List<AttriaxQueuedRequest> remaining;
  final bool shouldStop;
}

/// Dispatches queued requests to the Attriax backend through the generated SDK client.
///
/// Retries on transient errors (rate-limit, 5xx, network timeout) and
/// permanently drops requests that fail with a non-retryable 4xx.
class AttriaxRequestDispatcher {
  AttriaxRequestDispatcher({
    required AttriaxGeneratedTransport transport,
    required Connectivity connectivity,
    required AttriaxAppOpenMonitor appOpenMonitor,
    required AttriaxQueueManager queueManager,
    required AttriaxLogger logger,
    this.onDelivered,
    this.onFailed,
  }) : _transport = transport,
       _connectivity = connectivity,
       _appOpenMonitor = appOpenMonitor,
       _queueManager = queueManager,
       _logger = logger;

  final AttriaxGeneratedTransport _transport;
  final Connectivity _connectivity;
  final AttriaxAppOpenMonitor _appOpenMonitor;
  final AttriaxQueueManager _queueManager;
  final AttriaxLogger _logger;

  /// Called after a request is successfully delivered to the server.
  /// Receives the request kind and the HTTP status code.
  void Function(AttriaxApiRequest request, int statusCode)? onDelivered;

  /// Called after a request fails permanently (non-retryable error or 4xx).
  /// Receives the request kind and the error.
  void Function(AttriaxApiRequest request, Object error)? onFailed;

  bool _isFlushing = false;
  final Map<String, AttriaxSuccessHandler> _successHandlers = {};
  final Map<String, AttriaxErrorHandler> _errorHandlers = {};

  void registerHandlers(
    String requestId, {
    AttriaxSuccessHandler? onSuccess,
    AttriaxErrorHandler? onError,
  }) {
    if (onSuccess != null) {
      _successHandlers[requestId] = onSuccess;
    }
    if (onError != null) {
      _errorHandlers[requestId] = onError;
    }
  }

  void clearPending({required Object error, StackTrace? stackTrace}) {
    final errorHandlers = _errorHandlers.values.toList(growable: false);
    _successHandlers.clear();
    _errorHandlers.clear();
    for (final handler in errorHandlers) {
      handler(error, stackTrace);
    }
  }

  Future<void> flush() async {
    if (_isFlushing) {
      _logger.verbose(
        'Skipping queue flush because another flush is already running.',
      );
      return;
    }

    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.every((r) => r == ConnectivityResult.none)) {
      _logger.verbose('Skipping queue flush because the device is offline.');
      return;
    }

    _isFlushing = true;
    try {
      final queue = _prioritizeAppOpenRequests(await _queueManager.readAll());
      if (queue.isEmpty) {
        return;
      }

      _logger.verbose('Flushing ${queue.length} queued Attriax request(s).');

      final remaining = <AttriaxQueuedRequest>[];

      for (var i = 0; i < queue.length;) {
        final queuedRequest = queue[i];
        final request = queuedRequest.request;

        final dropReason = _terminalDropReason(queuedRequest);
        if (dropReason != null) {
          _logger.warning(
            'Dropping queued ${attriaxApiRequestLabel(request)} request because it exceeded the retry policy: $dropReason.',
          );
          final error = StateError(
            'Attriax request dropped after exceeding the retry policy: $dropReason.',
          );
          onFailed?.call(request, error);
          _clearHandlers(queuedRequest.id, error: error, stackTrace: null);
          await _queueManager.recordTerminalDrop(<AttriaxQueuedRequest>[
            queuedRequest,
          ], reason: dropReason);
          i += 1;
          continue;
        }

        if (_isWaitingForRetryWindow(queuedRequest)) {
          _logger.verbose(
            'Deferring queued ${attriaxApiRequestLabel(request)} request until retry backoff expires.',
          );
          remaining.add(queuedRequest);
          i += 1;
          continue;
        }

        if (!_canDispatchRequest(request)) {
          _logger.verbose(
            'Deferring queued ${attriaxApiRequestLabel(request)} request until app-open succeeds.',
          );
          remaining.add(queuedRequest);
          i += 1;
          continue;
        }

        if (attriaxCanBatchRequest(request)) {
          final batch = <AttriaxQueuedRequest>[queuedRequest];
          var batchEnd = i + 1;
          while (batchEnd < queue.length &&
              attriaxCanBatchRequest(queue[batchEnd].request) &&
              attriaxCanShareBatchRequest(
                queuedRequest.request,
                queue[batchEnd].request,
              )) {
            batch.add(queue[batchEnd]);
            batchEnd += 1;
          }

          final batchResult = await _flushBatchRequests(batch);
          if (batchResult.shouldStop) {
            remaining.addAll(batchResult.remaining);
            i = batchEnd;
            continue;
          }

          i = batchEnd;
          continue;
        }

        final label = attriaxApiRequestLabel(request);

        try {
          _logger.verbose('Sending $label request.');
          final delivery = await _transport.send(request);

          _logger.verbose(
            '$label request succeeded with HTTP ${delivery.statusCode}.',
          );
          onDelivered?.call(request, delivery.statusCode);
          _successHandlers.remove(queuedRequest.id)?.call(delivery.response);
          _errorHandlers.remove(queuedRequest.id);
          i += 1;
          continue;
        } catch (error, stackTrace) {
          if (_isAppOpenRequest(request)) {
            final attemptedAt = DateTime.now().toUtc();
            final action = _handleAppOpenFailure(
              requestId: queuedRequest.id,
              error: error,
              stackTrace: stackTrace,
              hasPendingAppOpenAfter: _hasPendingAppOpen(
                queue,
                startIndex: i + 1,
              ),
            );
            if (action == _DispatchFailureAction.retry) {
              remaining.add(_markForRetry(queuedRequest, error, attemptedAt));
              i += 1;
              continue;
            }

            i += 1;
            continue;
          }

          final action = _handleFailure(
            request: request,
            requestId: queuedRequest.id,
            label: label,
            error: error,
            stackTrace: stackTrace,
          );
          if (action == _DispatchFailureAction.retry) {
            final attemptedAt = DateTime.now().toUtc();
            remaining.add(_markForRetry(queuedRequest, error, attemptedAt));
            i += 1;
            continue;
          }
        }

        i += 1;
      }

      await _queueManager.writeAll(remaining);
    } finally {
      _isFlushing = false;
    }
  }

  _DispatchFailureAction _handleAppOpenFailure({
    required String requestId,
    required Object error,
    required StackTrace stackTrace,
    required bool hasPendingAppOpenAfter,
  }) {
    final retryable = _isRetryableRequestError(error);
    if (!retryable && hasPendingAppOpenAfter) {
      _logger.warning(
        'App-open request failed permanently and will be dropped because another queued app-open request can still unblock delivery.',
        error: error,
        stackTrace: stackTrace,
      );
      _clearHandlers(requestId, error: error, stackTrace: stackTrace);
      return _DispatchFailureAction.drop;
    }

    _logger.warning(
      'App-open request failed and queued requests will remain blocked until an app-open request succeeds.',
      error: error,
      stackTrace: stackTrace,
    );
    return _DispatchFailureAction.retry;
  }

  _DispatchFailureAction _handleFailure({
    required AttriaxApiRequest request,
    required String requestId,
    required String label,
    required Object error,
    required StackTrace stackTrace,
  }) {
    onFailed?.call(request, error);

    switch (error) {
      case AttriaxTransportHttpException(statusCode: final statusCode):
        if (statusCode == 429 || statusCode >= 500) {
          _logger.warning(
            '$label request failed with HTTP $statusCode and will be retried.',
            error: error,
          );
          return _DispatchFailureAction.retry;
        }

        _logger.error(
          '$label request failed with non-retryable HTTP $statusCode and will be dropped.',
          error: error,
        );
        _clearHandlers(
          requestId,
          error: error,
          stackTrace: error.source?.stackTrace,
        );
        return _DispatchFailureAction.drop;
      case TimeoutException():
        _logger.warning(
          '$label request timed out and will be retried.',
          error: error,
          stackTrace: stackTrace,
        );
        return _DispatchFailureAction.retry;
      case DioException():
        _logger.warning(
          '$label request failed with a transport error and will be retried.',
          error: error,
          stackTrace: stackTrace,
        );
        return _DispatchFailureAction.retry;
      case AttriaxTransportInvalidResponseException():
        _logger.error(
          '$label request returned an invalid response and will be dropped.',
          error: error,
          stackTrace: stackTrace,
        );
        _clearHandlers(requestId, error: error, stackTrace: stackTrace);
        return _DispatchFailureAction.drop;
      default:
        _logger.error(
          'Unexpected $label request failure; dropping request.',
          error: error,
          stackTrace: stackTrace,
        );
        _clearHandlers(requestId, error: error, stackTrace: stackTrace);
        return _DispatchFailureAction.drop;
    }
  }

  Future<_BatchDispatchResult> _flushBatchRequests(
    List<AttriaxQueuedRequest> requests,
  ) async {
    try {
      _logger.verbose(
        'Sending batch request with ${requests.length} queued Attriax request(s).',
      );
      final delivery = await _transport.sendBatch(requests);
      _logger.verbose(
        'Batch request succeeded with HTTP ${delivery.statusCode} for ${requests.length} request(s).',
      );

      for (final queuedRequest in requests) {
        onDelivered?.call(queuedRequest.request, delivery.statusCode);
        _successHandlers.remove(queuedRequest.id)?.call(delivery.response);
        _errorHandlers.remove(queuedRequest.id);
      }

      return const _BatchDispatchResult.success();
    } catch (error, stackTrace) {
      if (_isRetryableBatchError(error)) {
        final attemptedAt = DateTime.now().toUtc();
        _logger.warning(
          'Batch request failed and will be retried.',
          error: error,
          stackTrace: stackTrace,
        );
        return _BatchDispatchResult.retry(
          requests
              .map(
                (queuedRequest) =>
                    _markForRetry(queuedRequest, error, attemptedAt),
              )
              .toList(growable: false),
        );
      }

      if (requests.length > 1) {
        final splitIndex = requests.length ~/ 2;
        _logger.warning(
          'Batch request failed and will be split into smaller requests.',
          error: error,
          stackTrace: stackTrace,
        );

        final firstHalf = await _flushBatchRequests(
          requests.sublist(0, splitIndex),
        );
        if (firstHalf.shouldStop) {
          return _BatchDispatchResult(
            remaining: <AttriaxQueuedRequest>[
              ...firstHalf.remaining,
              ...requests.sublist(splitIndex),
            ],
            shouldStop: true,
          );
        }

        return _flushBatchRequests(requests.sublist(splitIndex));
      }

      final singleRequest = requests.single;
      final attemptedAt = DateTime.now().toUtc();
      final action = _handleFailure(
        request: singleRequest.request,
        requestId: singleRequest.id,
        label: attriaxApiRequestLabel(singleRequest.request),
        error: error,
        stackTrace: stackTrace,
      );
      if (action == _DispatchFailureAction.retry) {
        return _BatchDispatchResult.retry(<AttriaxQueuedRequest>[
          _markForRetry(singleRequest, error, attemptedAt),
        ]);
      }

      return const _BatchDispatchResult.success();
    }
  }

  bool _isRetryableBatchError(Object error) => switch (error) {
    AttriaxTransportHttpException(statusCode: final statusCode) =>
      statusCode == 429 || statusCode >= 500,
    TimeoutException() => true,
    DioException() => true,
    _ => false,
  };

  bool _canDispatchRequest(AttriaxApiRequest request) {
    if (_isAppOpenRequest(request) || _isDeepLinkResolveRequest(request)) {
      return true;
    }

    return _appOpenMonitor.hasSuccessfulResult;
  }

  bool _isWaitingForRetryWindow(AttriaxQueuedRequest queuedRequest) {
    final retryAt = queuedRequest.nextRetryAt;
    return retryAt != null && retryAt.isAfter(DateTime.now().toUtc());
  }

  List<AttriaxQueuedRequest> _prioritizeAppOpenRequests(
    List<AttriaxQueuedRequest> queue,
  ) {
    final appOpenRequests = <AttriaxQueuedRequest>[];
    final otherRequests = <AttriaxQueuedRequest>[];

    for (final queuedRequest in queue) {
      if (_isAppOpenRequest(queuedRequest.request)) {
        appOpenRequests.add(queuedRequest);
      } else {
        otherRequests.add(queuedRequest);
      }
    }

    return <AttriaxQueuedRequest>[...appOpenRequests, ...otherRequests];
  }

  bool _hasPendingAppOpen(
    List<AttriaxQueuedRequest> queue, {
    required int startIndex,
  }) {
    for (var i = startIndex; i < queue.length; i += 1) {
      if (_isAppOpenRequest(queue[i].request)) {
        return true;
      }
    }

    return false;
  }

  bool _isRetryableRequestError(Object error) => switch (error) {
    AttriaxTransportHttpException(statusCode: final statusCode) =>
      statusCode == 429 || statusCode >= 500,
    TimeoutException() => true,
    DioException() => true,
    _ => false,
  };

  AttriaxQueuedRequest _markForRetry(
    AttriaxQueuedRequest queuedRequest,
    Object error,
    DateTime attemptedAt,
  ) => queuedRequest.copyWith(
    attemptCount: queuedRequest.attemptCount + 1,
    lastAttemptAt: attemptedAt,
    lastErrorClass: _retryErrorClass(error),
    lastHttpStatusCode: _httpStatusCode(error),
    nextRetryAt: _retryAfterAt(error, attemptedAt),
  );

  String _retryErrorClass(Object error) => switch (error) {
    AttriaxTransportHttpException(statusCode: final statusCode) =>
      'http_$statusCode',
    TimeoutException() => 'timeout',
    DioException() => 'transport',
    _ => error.runtimeType.toString(),
  };

  int? _httpStatusCode(Object error) => switch (error) {
    AttriaxTransportHttpException(statusCode: final statusCode) => statusCode,
    _ => null,
  };

  String? _terminalDropReason(AttriaxQueuedRequest queuedRequest) {
    if (!_shouldApplyTerminalRetryPolicy(queuedRequest.request)) {
      return null;
    }

    if (queuedRequest.attemptCount >= _attriaxMaxRetryAttempts) {
      return 'max_attempts_exceeded';
    }

    final age = DateTime.now().toUtc().difference(queuedRequest.createdAt);
    if (age > _attriaxMaxRetryAge) {
      return 'max_age_exceeded';
    }

    return null;
  }

  bool _shouldApplyTerminalRetryPolicy(AttriaxApiRequest request) =>
      request is! AttriaxResolveDeepLinkRequest;

  DateTime? _retryAfterAt(Object error, DateTime attemptedAt) {
    switch (error) {
      case AttriaxTransportHttpException():
        final retryAfterValue = error.headerValue('retry-after');
        if (retryAfterValue == null) {
          return null;
        }

        final trimmed = retryAfterValue.trim();
        if (trimmed.isEmpty) {
          return null;
        }

        final retryAfterSeconds = int.tryParse(trimmed);
        if (retryAfterSeconds != null) {
          if (retryAfterSeconds < 0) {
            return null;
          }
          return attemptedAt.add(Duration(seconds: retryAfterSeconds));
        }

        final retryAfterDate = DateTime.tryParse(trimmed)?.toUtc();
        final httpRetryAfterDate = _parseHttpRetryAfterDate(trimmed);
        final parsedRetryAfterDate = httpRetryAfterDate ?? retryAfterDate;
        if (parsedRetryAfterDate == null ||
            !parsedRetryAfterDate.isAfter(attemptedAt)) {
          return null;
        }

        return parsedRetryAfterDate;
      default:
        return null;
    }
  }

  DateTime? _parseHttpRetryAfterDate(String value) {
    final match = _httpRetryAfterPattern.firstMatch(value);
    if (match == null) {
      return null;
    }

    final month = _httpRetryAfterMonths[match.group(2)!];
    if (month == null) {
      return null;
    }

    try {
      return DateTime.utc(
        int.parse(match.group(3)!),
        month,
        int.parse(match.group(1)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
      );
    } on FormatException {
      return null;
    }
  }

  bool _isAppOpenRequest(AttriaxApiRequest request) =>
      request is AttriaxOpenRequest;

  bool _isDeepLinkResolveRequest(AttriaxApiRequest request) =>
      request is AttriaxResolveDeepLinkRequest;

  void _clearHandlers(
    String requestId, {
    required Object error,
    required StackTrace? stackTrace,
  }) {
    _successHandlers.remove(requestId);
    _errorHandlers.remove(requestId)?.call(error, stackTrace);
  }
}

final RegExp _httpRetryAfterPattern = RegExp(
  r'^[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
);

const Map<String, int> _httpRetryAfterMonths = <String, int>{
  'Jan': 1,
  'Feb': 2,
  'Mar': 3,
  'Apr': 4,
  'May': 5,
  'Jun': 6,
  'Jul': 7,
  'Aug': 8,
  'Sep': 9,
  'Oct': 10,
  'Nov': 11,
  'Dec': 12,
};
