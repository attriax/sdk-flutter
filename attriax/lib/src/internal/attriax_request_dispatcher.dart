import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'attriax_api_models.dart';
import 'attriax_generated_transport.dart';
import 'attriax_json_utils.dart';
import 'attriax_logger.dart';
import 'attriax_queue.dart';
import 'dispatch/batch_limits.dart';
import 'dispatch/request_retry_policy.dart';

typedef AttriaxSuccessHandler = void Function(AttriaxApiResponse response);
typedef AttriaxErrorHandler =
    void Function(Object error, StackTrace? stackTrace);

enum _DispatchFailureAction { retry, drop }

class _BatchDispatchResult {
  const _BatchDispatchResult({
    required this.remaining,
    required this.shouldStop,
  });

  /// The batch needs no further work this flush: every item was either
  /// delivered or permanently dropped (handlers already notified). The name is
  /// intentionally not "success" — a dropped non-retryable request also settles
  /// here.
  const _BatchDispatchResult.settled()
    : remaining = const <AttriaxQueuedRequest>[],
      shouldStop = false;

  const _BatchDispatchResult.retry(List<AttriaxQueuedRequest> requests)
    : remaining = requests,
      shouldStop = true;

  final List<AttriaxQueuedRequest> remaining;
  final bool shouldStop;
}

class _BatchKeepAliveRequest {
  const _BatchKeepAliveRequest({
    required this.sessionId,
    required this.occurredAt,
    required this.request,
  });

  final String sessionId;
  final DateTime occurredAt;
  final AttriaxQueuedRequest request;
}

class _PreparedBatchRequest {
  const _PreparedBatchRequest({
    required this.queuedRequests,
    required this.transportRequests,
    required this.keepAlive,
  });

  final List<AttriaxQueuedRequest> queuedRequests;
  final List<AttriaxQueuedRequest> transportRequests;
  final _BatchKeepAliveRequest? keepAlive;
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
    this.buildSessionKeepAliveBatchRequest,
    this.onSessionKeepAliveDelivered,
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

  final AttriaxTrackSessionRequest? Function(
    List<AttriaxQueuedRequest> requests,
  )?
  buildSessionKeepAliveBatchRequest;

  final FutureOr<void> Function(String sessionId, DateTime occurredAt)?
  onSessionKeepAliveDelivered;

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

        final dropReason = attriaxTerminalDropReason(queuedRequest);
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

        if (attriaxCanBatchRequest(request)) {
          final batch = _collectSendableBatchRequests(queue, startIndex: i);

          final batchResult = await _flushBatchRequests(batch);
          if (batchResult.shouldStop) {
            remaining.addAll(batchResult.remaining);
            i += batch.length;
            continue;
          }

          i += batch.length;
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
            final attemptedAt = DateTime.now().toUtc();
            remaining.add(
              attriaxMarkRequestForRetry(queuedRequest, error, attemptedAt),
            );
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
        if (attriaxIsRetryableHttpStatus(statusCode)) {
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
    final preparedBatch = _prepareBatchRequest(requests);

    try {
      _logger.verbose(
        'Sending batch request with ${preparedBatch.transportRequests.length} queued Attriax request(s).',
      );
      final delivery = await _transport.sendBatch(
        preparedBatch.transportRequests,
      );
      _logger.verbose(
        'Batch request succeeded with HTTP ${delivery.statusCode} for ${preparedBatch.transportRequests.length} request(s).',
      );

      for (final queuedRequest in preparedBatch.queuedRequests) {
        onDelivered?.call(queuedRequest.request, delivery.statusCode);
        _successHandlers.remove(queuedRequest.id)?.call(delivery.response);
        _errorHandlers.remove(queuedRequest.id);
      }

      final keepAlive = preparedBatch.keepAlive;
      if (keepAlive != null) {
        await onSessionKeepAliveDelivered?.call(
          keepAlive.sessionId,
          keepAlive.occurredAt,
        );
      }

      return const _BatchDispatchResult.settled();
    } catch (error, stackTrace) {
      if (attriaxIsRetryableRequestError(error)) {
        final attemptedAt = DateTime.now().toUtc();
        _logger.warning(
          'Batch request failed and will be retried.',
          error: error,
          stackTrace: stackTrace,
        );
        return _BatchDispatchResult.retry(
          requests
              .map(
                (queuedRequest) => attriaxMarkRequestForRetry(
                  queuedRequest,
                  error,
                  attemptedAt,
                ),
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
          attriaxMarkRequestForRetry(singleRequest, error, attemptedAt),
        ]);
      }

      return const _BatchDispatchResult.settled();
    }
  }

  List<AttriaxQueuedRequest> _collectSendableBatchRequests(
    List<AttriaxQueuedRequest> queue, {
    required int startIndex,
  }) {
    final requests = <AttriaxQueuedRequest>[];

    for (var index = startIndex; index < queue.length; index += 1) {
      final queuedRequest = queue[index];
      if (!attriaxCanBatchRequest(queuedRequest.request)) {
        break;
      }

      final firstQueuedRequest = requests.isEmpty ? null : requests.first;
      if (firstQueuedRequest != null &&
          !attriaxCanShareBatchRequest(
            firstQueuedRequest.request,
            queuedRequest.request,
          )) {
        break;
      }

      requests.add(queuedRequest);
      if (!_fitsBatchRequest(requests)) {
        requests.removeLast();
        break;
      }
    }

    if (requests.isNotEmpty) {
      return requests;
    }

    return <AttriaxQueuedRequest>[queue[startIndex]];
  }

  bool _fitsBatchRequest(List<AttriaxQueuedRequest> requests) {
    final preparedBatch = _prepareBatchRequest(requests);
    if (preparedBatch.transportRequests.isEmpty) {
      return false;
    }

    if (preparedBatch.transportRequests.length > attriaxMaxBatchRequestItems) {
      return false;
    }

    final encodedBody = utf8.encode(
      jsonEncode(
        attriaxNormalizeJsonMap(
          _buildBatchBody(preparedBatch.transportRequests),
        ),
      ),
    );
    return encodedBody.length <= attriaxMaxBatchRequestBodyBytes;
  }

  _PreparedBatchRequest _prepareBatchRequest(
    List<AttriaxQueuedRequest> requests,
  ) {
    final keepAliveRequest = buildSessionKeepAliveBatchRequest?.call(requests);
    if (keepAliveRequest == null) {
      return _PreparedBatchRequest(
        queuedRequests: List<AttriaxQueuedRequest>.from(requests),
        transportRequests: List<AttriaxQueuedRequest>.from(requests),
        keepAlive: null,
      );
    }

    final syntheticKeepAliveRequest = AttriaxQueuedRequest(
      id: 'keepalive_${keepAliveRequest.payload.sessionId}_${keepAliveRequest.payload.clientOccurredAt.microsecondsSinceEpoch}',
      request: keepAliveRequest,
      createdAt: keepAliveRequest.payload.clientOccurredAt,
    );

    return _PreparedBatchRequest(
      queuedRequests: List<AttriaxQueuedRequest>.from(requests),
      transportRequests: <AttriaxQueuedRequest>[
        ...requests,
        syntheticKeepAliveRequest,
      ],
      keepAlive: _BatchKeepAliveRequest(
        sessionId: keepAliveRequest.payload.sessionId,
        occurredAt: keepAliveRequest.payload.clientOccurredAt,
        request: syntheticKeepAliveRequest,
      ),
    );
  }

  Map<String, Object?> _buildBatchBody(List<AttriaxQueuedRequest> requests) {
    final firstQueuedRequest = requests.first;
    final sharedIdentity = attriaxBatchRequestIdentity(
      firstQueuedRequest.request,
    );

    return <String, Object?>{
      'requestId': attriaxBatchRequestId(firstQueuedRequest.id),
      'appToken': sharedIdentity.appToken,
      'deviceId': sharedIdentity.deviceId,
      if (sharedIdentity.deviceIdSource != null)
        'deviceIdSource': sharedIdentity.deviceIdSource,
      'items': requests
          .map(
            (queuedRequest) => <String, Object?>{
              'kind': attriaxBatchKindName(queuedRequest.request),
              'body': attriaxBatchBody(queuedRequest.request),
            },
          )
          .toList(growable: false),
    };
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

  bool _isAppOpenRequest(AttriaxApiRequest request) =>
      request is AttriaxOpenRequest;

  void _clearHandlers(
    String requestId, {
    required Object error,
    required StackTrace? stackTrace,
  }) {
    _successHandlers.remove(requestId);
    _errorHandlers.remove(requestId)?.call(error, stackTrace);
  }
}
