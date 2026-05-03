import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'attriax_api_models.dart';
import 'attriax_generated_transport.dart';
import 'attriax_logger.dart';
import 'attriax_queue.dart';

typedef AttriaxSuccessHandler = void Function(AttriaxApiResponse response);
typedef AttriaxErrorHandler =
    void Function(Object error, StackTrace? stackTrace);

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
    required AttriaxQueueManager queueManager,
    required AttriaxLogger logger,
    this.onDelivered,
    this.onFailed,
  }) : _transport = transport,
       _connectivity = connectivity,
       _queueManager = queueManager,
       _logger = logger;

  final AttriaxGeneratedTransport _transport;
  final Connectivity _connectivity;
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
      final queue = await _queueManager.readAll();
      if (queue.isEmpty) {
        return;
      }

      _logger.verbose('Flushing ${queue.length} queued Attriax request(s).');

      final remaining = <AttriaxQueuedRequest>[];

      for (var i = 0; i < queue.length;) {
        final queuedRequest = queue[i];
        final request = queuedRequest.request;

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
            remaining
              ..addAll(batchResult.remaining)
              ..addAll(queue.skip(batchEnd));
            break;
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
          final action = _handleFailure(
            request: request,
            requestId: queuedRequest.id,
            label: label,
            error: error,
            stackTrace: stackTrace,
          );
          if (action == _DispatchFailureAction.retry) {
            remaining
              ..add(queuedRequest)
              ..addAll(queue.skip(i + 1));
            break;
          }
        }

        i += 1;
      }

      await _queueManager.writeAll(remaining);
    } finally {
      _isFlushing = false;
    }
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
        _logger.warning(
          'Batch request failed and will be retried.',
          error: error,
          stackTrace: stackTrace,
        );
        return _BatchDispatchResult.retry(requests);
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
      final action = _handleFailure(
        request: singleRequest.request,
        requestId: singleRequest.id,
        label: attriaxApiRequestLabel(singleRequest.request),
        error: error,
        stackTrace: stackTrace,
      );
      if (action == _DispatchFailureAction.retry) {
        return _BatchDispatchResult.retry(requests);
      }

      return const _BatchDispatchResult.success();
    }
  }

  bool _isRetryableBatchError(Object error) {
    return switch (error) {
      AttriaxTransportHttpException(statusCode: final statusCode) =>
        statusCode == 429 || statusCode >= 500,
      TimeoutException() => true,
      DioException() => true,
      _ => false,
    };
  }

  void _clearHandlers(
    String requestId, {
    required Object error,
    required StackTrace? stackTrace,
  }) {
    _successHandlers.remove(requestId);
    _errorHandlers.remove(requestId)?.call(error, stackTrace);
  }
}
