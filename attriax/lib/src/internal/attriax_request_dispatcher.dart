import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'attriax_api_models.dart';
import 'attriax_json_utils.dart';
import 'attriax_logger.dart';
import 'attriax_queue.dart';

typedef AttriaxSuccessHandler = void Function(AttriaxApiResponse response);
typedef AttriaxErrorHandler =
    void Function(Object error, StackTrace? stackTrace);

/// Dispatches queued requests to the Attriax backend over HTTP.
///
/// Retries on transient errors (rate-limit, 5xx, network timeout) and
/// permanently drops requests that fail with a non-retryable 4xx.
class AttriaxRequestDispatcher {
  AttriaxRequestDispatcher({
    required String apiBaseUrl,
    required http.Client client,
    required Duration requestTimeout,
    required Connectivity connectivity,
    required AttriaxQueueManager queueManager,
    required AttriaxLogger logger,
    this.onDelivered,
    this.onFailed,
  }) : _apiBaseUrl = apiBaseUrl.endsWith('/')
           ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
           : apiBaseUrl,
       _client = client,
       _requestTimeout = requestTimeout,
       _connectivity = connectivity,
       _queueManager = queueManager,
       _logger = logger;

  final String _apiBaseUrl;
  final http.Client _client;
  final Duration _requestTimeout;
  final Connectivity _connectivity;
  final AttriaxQueueManager _queueManager;
  final AttriaxLogger _logger;

  /// Called after a request is successfully delivered to the server.
  /// Receives the endpoint path and the HTTP status code.
  void Function(String path, int statusCode)? onDelivered;

  /// Called after a request fails permanently (non-retryable error or 4xx).
  /// Receives the endpoint path and the error.
  void Function(String path, Object error)? onFailed;

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

      for (var i = 0; i < queue.length; i++) {
        final request = queue[i];
        try {
          _logger.verbose(
            'Sending ${request.kind.name} request to ${request.path}.',
          );
          final response = await _client
              .post(
                Uri.parse('$_apiBaseUrl${request.path}'),
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode(request.body),
              )
              .timeout(_requestTimeout);

          final payload = _decodePayload(response);
          final statusCode = response.statusCode;

          if (statusCode >= 200 && statusCode < 300) {
            final parsedResponse = AttriaxApiResponseCodec.decode(
              request.kind,
              payload,
            );
            _logger.verbose(
              'Request to ${request.path} succeeded with HTTP $statusCode.',
            );
            onDelivered?.call(request.path, statusCode);
            _successHandlers.remove(request.id)?.call(parsedResponse);
            _errorHandlers.remove(request.id);
            continue;
          }

          final error = Exception(
            'Attriax API error ($statusCode): ${response.body}',
          );
          onFailed?.call(request.path, error);

          if (statusCode == 429 || statusCode >= 500) {
            _logger.warning(
              'Request to ${request.path} failed with HTTP $statusCode and will be retried.',
              error: error,
            );
            remaining
              ..add(request)
              ..addAll(queue.skip(i + 1));
            break;
          }

          _logger.error(
            'Request to ${request.path} failed with non-retryable HTTP $statusCode and will be dropped.',
            error: error,
          );
          _successHandlers.remove(request.id);
          _errorHandlers.remove(request.id)?.call(error, null);
        } on TimeoutException catch (error, stackTrace) {
          onFailed?.call(request.path, error);
          _logger.warning(
            'Request to ${request.path} timed out and will be retried.',
            error: error,
            stackTrace: stackTrace,
          );
          remaining
            ..add(request)
            ..addAll(queue.skip(i + 1));
          break;
        } on http.ClientException catch (error, stackTrace) {
          onFailed?.call(request.path, error);
          _logger.warning(
            'Request to ${request.path} failed with a transport error and will be retried.',
            error: error,
            stackTrace: stackTrace,
          );
          remaining
            ..add(request)
            ..addAll(queue.skip(i + 1));
          break;
        } on FormatException catch (error, stackTrace) {
          onFailed?.call(request.path, error);
          _logger.error(
            'Request to ${request.path} returned an invalid response and will be dropped.',
            error: error,
            stackTrace: stackTrace,
          );
          _successHandlers.remove(request.id);
          _errorHandlers.remove(request.id)?.call(error, stackTrace);
        } catch (error, stackTrace) {
          onFailed?.call(request.path, error);
          _logger.error(
            'Unexpected request failure for ${request.path}; dropping request.',
            error: error,
            stackTrace: stackTrace,
          );
          _successHandlers.remove(request.id);
          _errorHandlers.remove(request.id)?.call(error, stackTrace);
        }
      }

      await _queueManager.writeAll(remaining);
    } finally {
      _isFlushing = false;
    }
  }

  Map<String, Object?> _decodePayload(http.Response response) {
    if (response.body.isEmpty) {
      return const <String, Object?>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      return const <String, Object?>{};
    }
    final payload = attriaxObjectMapOrEmpty(decoded);
    final data = attriaxObjectMap(payload['data']);
    return data ?? payload;
  }
}
