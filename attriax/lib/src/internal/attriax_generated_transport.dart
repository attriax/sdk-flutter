import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:attriax_platform_interface/attriax_platform_interface.dart';
import 'package:attriax_sdk_client/attriax_sdk_client.dart' as sdk;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'attriax_api_models.dart';
import 'attriax_json_utils.dart';
import 'attriax_queue.dart';

const int _attriaxBatchMaxItemCount = 100;
const int _attriaxBatchMaxBodyBytes = 48 * 1024;

class AttriaxTransportSuccess {
  const AttriaxTransportSuccess({
    required this.statusCode,
    required this.response,
  });

  final int statusCode;
  final AttriaxApiResponse response;
}

class AttriaxTransportHttpException implements Exception {
  const AttriaxTransportHttpException({
    required this.statusCode,
    this.body,
    this.source,
  });

  final int statusCode;
  final Object? body;
  final DioException? source;
}

class AttriaxTransportInvalidResponseException implements Exception {
  const AttriaxTransportInvalidResponseException(this.message, {this.source});

  final String message;
  final DioException? source;

  @override
  String toString() => message;
}

class AttriaxGeneratedTransport {
  factory AttriaxGeneratedTransport({
    required String apiBaseUrl,
    required Duration requestTimeout,
    required http.Client httpClient,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: requestTimeout,
        receiveTimeout: requestTimeout,
        sendTimeout: requestTimeout,
      ),
    )..httpClientAdapter = AttriaxDioHttpClientAdapter(httpClient);

    return AttriaxGeneratedTransport._(
      sdk.AttriaxSdkClient(dio: dio).getSdkApi(),
      dio,
    );
  }

  AttriaxGeneratedTransport._(this._sdkApi, this._dio);

  final sdk.SdkApi _sdkApi;
  final Dio _dio;

  Future<AttriaxTransportSuccess> send(AttriaxApiRequest request) async {
    final label = request.label;

    try {
      return switch (request) {
        AttriaxOpenRequest(:final payload) => await _sendGeneratedRequest(
          label: label,
          invoke: () => _sdkApi.sdkControllerOpenV1(
            sdkV1OpenDto: payload,
            validateStatus: _allowAnyStatus,
          ),
          mapper: attriaxOpenResponseFromGenerated,
        ),
        AttriaxTrackEventRequest(:final payload) => await _sendGeneratedRequest(
          label: label,
          invoke: () => _sdkApi.sdkControllerRecordEventV1(
            sdkEventDto: payload,
            validateStatus: _allowAnyStatus,
          ),
          mapper: attriaxAckResponseFromGenerated,
        ),
        AttriaxTrackCrashRequest(:final payload) =>
          await _sendCrashReportRequest(payload),
        AttriaxTrackSessionRequest(:final payload) =>
          await _sendGeneratedRequest(
            label: label,
            invoke: () => _sdkApi.sdkControllerRecordSessionV1(
              sdkSessionDto: attriaxGeneratedTrackSessionDto(payload),
              validateStatus: _allowAnyStatus,
            ),
            mapper: attriaxAckResponseFromGenerated,
          ),
        AttriaxUserRequest(:final payload) => await _sendGeneratedRequest(
          label: label,
          invoke: () => _sdkApi.sdkControllerSetUserV1(
            sdkUserDto: payload,
            validateStatus: _allowAnyStatus,
          ),
          mapper: attriaxAckResponseFromGenerated,
        ),
        AttriaxResolveDeepLinkRequest(:final payload) =>
          await _sendGeneratedRequest(
            label: label,
            invoke: () => _sdkApi.sdkControllerResolveDeepLinkV1(
              sdkV1DeepLinkResolveDto: payload,
              validateStatus: _allowAnyStatus,
            ),
            mapper: attriaxResolveDeepLinkResponseFromGenerated,
          ),
        AttriaxCreateDynamicLinkRequest(:final payload) =>
          await _sendGeneratedRequest(
            label: label,
            invoke: () => _sdkApi.sdkControllerCreateDynamicLinkV1(
              sdkCreateDynamicLinkDto: payload,
              validateStatus: _allowAnyStatus,
            ),
            mapper: attriaxCreateDynamicLinkResponseFromGenerated,
          ),
      };
    } on DioException catch (error) {
      _rethrowDioException(label, error);
    }
  }

  Future<AttriaxTransportSuccess> sendBatch(
    List<AttriaxQueuedRequest> requests,
  ) async {
    if (requests.isEmpty) {
      throw ArgumentError.value(
        requests,
        'requests',
        'Batch requests are required.',
      );
    }

    final firstQueuedRequest = requests.first;
    final batchRequestId = attriaxBatchRequestId(firstQueuedRequest.id);
    final sharedIdentity = attriaxBatchRequestIdentity(
      firstQueuedRequest.request,
    );
    for (final queuedRequest in requests.skip(1)) {
      if (!attriaxCanShareBatchRequest(
        firstQueuedRequest.request,
        queuedRequest.request,
      )) {
        throw const AttriaxTransportHttpException(statusCode: 400);
      }
    }

    final body = <String, Object?>{
      'requestId': batchRequestId,
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

    final encodedBody = utf8.encode(jsonEncode(attriaxNormalizeJsonMap(body)));
    if (requests.length > _attriaxBatchMaxItemCount ||
        encodedBody.length > _attriaxBatchMaxBodyBytes) {
      throw const AttriaxTransportHttpException(statusCode: 413);
    }

    final batchDto = sdk.SdkV1BatchDto(
      (builder) => builder
        ..requestId = batchRequestId
        ..appToken = sharedIdentity.appToken
        ..deviceId = sharedIdentity.deviceId
        ..deviceIdSource = attriaxStringValue(sharedIdentity.deviceIdSource)
        ..items.addAll(
          requests.map(
            (queuedRequest) => sdk.SdkV1BatchItemDto(
              (itemBuilder) => itemBuilder
                ..kind = attriaxGeneratedBatchItemKind(queuedRequest.request)
                ..body = attriaxGeneratedJsonObjectMap(
                  attriaxBatchBody(queuedRequest.request),
                ).toBuilder(),
            ),
          ),
        ),
    );

    try {
      return await _sendGeneratedRequest(
        label: 'batch',
        invoke: () => _sdkApi.sdkControllerBatchV1(
          sdkV1BatchDto: batchDto,
          validateStatus: _allowAnyStatus,
        ),
        mapper: (_) => const AttriaxAckResponse(success: true),
      );
    } on DioException catch (error) {
      _rethrowDioException('batch', error);
    }
  }

  Future<AttriaxCreateDynamicLinkResult> createDynamicLink(
    AttriaxCreateDynamicLinkRequest request,
  ) async {
    final result = await send(request);
    final response = result.response;
    if (response is! AttriaxCreateDynamicLinkApiResponse) {
      throw const AttriaxTransportInvalidResponseException(
        'Unexpected dynamic-link response type.',
      );
    }
    return response.result;
  }

  Future<AttriaxTransportSuccess> _sendCrashReportRequest(
    AttriaxCrashReportPayload payload,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/sdk/v1/crashes',
      data: attriaxNormalizeJsonMap(payload.toJson()),
      options: Options(validateStatus: _allowAnyStatus),
    );

    return _unwrapAckLikeResponse(label: 'crash report', response: response);
  }

  Future<AttriaxTransportSuccess> _sendGeneratedRequest<T>({
    required String label,
    required Future<Response<T>> Function() invoke,
    required AttriaxApiResponse Function(T envelope) mapper,
  }) async {
    final response = await invoke();
    return _unwrapResponse(label: label, response: response, mapper: mapper);
  }

  AttriaxTransportSuccess _unwrapResponse<T>({
    required String label,
    required Response<T> response,
    required AttriaxApiResponse Function(T envelope) mapper,
  }) {
    final statusCode = response.statusCode ?? 0;
    if (!_isSuccessful(statusCode)) {
      throw AttriaxTransportHttpException(
        statusCode: statusCode,
        body: response.data,
      );
    }

    final envelope = response.data;
    if (envelope == null) {
      throw AttriaxTransportInvalidResponseException(
        'Missing $label response body.',
      );
    }

    return AttriaxTransportSuccess(
      statusCode: statusCode,
      response: mapper(envelope),
    );
  }

  AttriaxTransportSuccess _unwrapAckLikeResponse({
    required String label,
    required Response<Object?> response,
  }) {
    final statusCode = response.statusCode ?? 0;
    if (!_isSuccessful(statusCode)) {
      throw AttriaxTransportHttpException(
        statusCode: statusCode,
        body: response.data,
      );
    }

    final body = attriaxObjectMap(response.data);
    return AttriaxTransportSuccess(
      statusCode: statusCode,
      response: body == null
          ? const AttriaxAckResponse(success: true)
          : attriaxAckResponseFromJsonEnvelope(body),
    );
  }

  Never _rethrowDioException(String label, DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      if (_isSuccessful(statusCode)) {
        throw AttriaxTransportInvalidResponseException(
          'Invalid $label response body.',
          source: error,
        );
      }

      throw AttriaxTransportHttpException(
        statusCode: statusCode,
        body: error.response?.data,
        source: error,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException('The $label request timed out.');
      default:
        throw error;
    }
  }

  bool _isSuccessful(int statusCode) => statusCode >= 200 && statusCode < 300;

  bool _allowAnyStatus(int? _) => true;
}

class AttriaxDioHttpClientAdapter implements HttpClientAdapter {
  AttriaxDioHttpClientAdapter(this._client);

  final http.Client _client;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    try {
      final request = http.Request(options.method, options.uri);
      options.headers.forEach((key, value) {
        if (value != null) {
          request.headers[key] = value.toString();
        }
      });

      final bodyBytes = await _readBodyBytes(options, requestStream);
      if (bodyBytes != null) {
        request.bodyBytes = bodyBytes;
      }

      final streamedResponse = await _client.send(request);

      return ResponseBody(
        streamedResponse.stream.map(Uint8List.fromList),
        streamedResponse.statusCode,
        headers: streamedResponse.headers.map(
          (key, value) => MapEntry(key, <String>[value]),
        ),
        isRedirect: streamedResponse.isRedirect,
        statusMessage: streamedResponse.reasonPhrase,
      );
    } on http.ClientException catch (error, stackTrace) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void close({bool force = false}) {}

  Future<Uint8List?> _readBodyBytes(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
  ) async {
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      return Uint8List.fromList(chunks.expand((chunk) => chunk).toList());
    }

    final data = options.data;
    if (data == null) {
      return null;
    }
    if (data is Uint8List) {
      return data;
    }
    if (data is List<int>) {
      return Uint8List.fromList(data);
    }
    if (data is String) {
      return Uint8List.fromList(utf8.encode(data));
    }

    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }
}
