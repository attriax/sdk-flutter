import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:attriax_flutter_platform_interface/attriax_runtime_types.dart';
import 'package:attriax_api_client/attriax_api_client.dart' as sdk;
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'attriax_api_models.dart';
import 'attriax_json_utils.dart';
import 'attriax_queue.dart';
import 'attriax_sdk_runtime_config.dart';

const int _attriaxBatchMaxItemCount = 100;
const int _attriaxBatchMaxBodyBytes = 48 * 1024;

String _resolveTransportProjectToken({
  required String context,
  String? projectToken,
  String? appToken,
}) {
  final normalizedProjectToken = projectToken?.trim();
  final normalizedAppToken = appToken?.trim();

  if (normalizedProjectToken != null &&
      normalizedAppToken != null &&
      normalizedProjectToken != normalizedAppToken) {
    throw ArgumentError(
      '$context received mismatched projectToken and deprecated appToken values.',
    );
  }

  final resolvedToken = normalizedProjectToken ?? normalizedAppToken;
  if (resolvedToken == null || resolvedToken.isEmpty) {
    throw ArgumentError(
      '$context requires projectToken or the deprecated appToken alias.',
    );
  }

  return resolvedToken;
}

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
    this.headers,
    this.source,
  });

  final int statusCode;
  final Object? body;
  final Headers? headers;
  final DioException? source;

  String? headerValue(String name) =>
      headers?.value(name) ?? source?.response?.headers.value(name);

  @override
  String toString() {
    final buffer = StringBuffer('Attriax request failed with HTTP $statusCode');

    final sourceMessage = source?.message?.trim();
    if (sourceMessage != null && sourceMessage.isNotEmpty) {
      buffer.write(': $sourceMessage');
    }

    final responseBody = body;
    if (responseBody != null) {
      buffer.write(
        '. Response body: ${_attriaxSummarizeErrorBody(responseBody)}',
      );
    } else {
      buffer.write('.');
    }

    return buffer.toString();
  }
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
      sdk.AttriaxApiClient(dio: dio).getSdkApi(),
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
        AttriaxOpenRequest() => await _sendJsonOpenRequest(request),
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
        AttriaxTrackNotificationRequest(:final payload) =>
          await _sendGeneratedRequest(
            label: label,
            invoke: () => _sdkApi.sdkControllerRecordNotificationV1(
              sdkNotificationDto: payload,
              validateStatus: _allowAnyStatus,
            ),
            mapper: attriaxAckResponseFromGenerated,
          ),
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
        AttriaxRegisterUninstallTokenRequest(:final payload) =>
          await _sendUninstallTokenRequest(payload),
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
      appToken: sharedIdentity.appToken,
      deviceId: sharedIdentity.deviceId,
      deviceIdSource: attriaxStringValue(sharedIdentity.deviceIdSource),
      items: requests
          .map(
            (queuedRequest) => sdk.SdkV1BatchItemDto(
              body: attriaxGeneratedJsonObjectMap(
                attriaxBatchBody(queuedRequest.request),
              ),
              kind: attriaxGeneratedBatchItemKind(queuedRequest.request),
            ),
          )
          .toList(growable: false),
      requestId: batchRequestId,
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

  Future<sdk.SdkGdprConsentStatusDto> checkGdprConsent({
    String? projectToken,
    @Deprecated('Use projectToken instead.') String? appToken,
    required String consentId,
  }) async {
    final resolvedToken = _resolveTransportProjectToken(
      context: 'Attriax GDPR consent check',
      projectToken: projectToken,
      appToken: appToken,
    );

    try {
      final response = await _sdkApi.sdkControllerCheckGdprConsentV1(
        sdkV1GdprConsentCheckDto: sdk.SdkV1GdprConsentCheckDto(
          appToken: resolvedToken,
          consentId: consentId,
        ),
        validateStatus: _allowAnyStatus,
      );

      return _unwrapGdprConsentResponse(
        label: 'gdpr consent check',
        response: response,
      );
    } on DioException catch (error) {
      _rethrowDioException('gdpr consent check', error);
    }
  }

  Future<sdk.SdkGdprConsentStatusDto> upsertGdprConsent({
    String? projectToken,
    @Deprecated('Use projectToken instead.') String? appToken,
    required String consentId,
    required sdk.AppUserGdprConsentState state,
    sdk.SdkV1GdprConsentValuesDto? values,
    String? countryCode,
    String? regionSource,
    DateTime? clientOccurredAt,
  }) async {
    final resolvedToken = _resolveTransportProjectToken(
      context: 'Attriax GDPR consent upsert',
      projectToken: projectToken,
      appToken: appToken,
    );

    try {
      final response = await _sdkApi.sdkControllerUpsertGdprConsentV1(
        sdkV1GdprConsentWriteDto: sdk.SdkV1GdprConsentWriteDto(
          appToken: resolvedToken,
          consentId: consentId,
          state: state,
          values: values,
          countryCode: countryCode,
          regionSource: regionSource,
          clientOccurredAt: clientOccurredAt,
        ),
        validateStatus: _allowAnyStatus,
      );

      return _unwrapGdprConsentResponse(
        label: 'gdpr consent upsert',
        response: response,
      );
    } on DioException catch (error) {
      _rethrowDioException('gdpr consent upsert', error);
    }
  }

  Future<AttriaxSdkRuntimeConfig> fetchSdkRuntimeConfig(
    Map<String, Object?> payload,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/sdk/v1/config',
      data: attriaxNormalizeJsonMap(payload),
      options: Options(validateStatus: _allowAnyStatus),
    );

    final statusCode = response.statusCode ?? 0;
    if (!_isSuccessful(statusCode)) {
      throw AttriaxTransportHttpException(
        statusCode: statusCode,
        body: response.data,
      );
    }

    final body = attriaxObjectMap(response.data);
    if (body == null) {
      throw const AttriaxTransportInvalidResponseException(
        'Missing runtime config response body.',
      );
    }

    return AttriaxSdkRuntimeConfig.fromJsonEnvelope(body);
  }

  Future<AttriaxRevenueReceiptValidationResult> validateRevenueReceipt(
    Map<String, Object?> payload,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/sdk/v1/revenue/receipts/validate',
      data: attriaxNormalizeJsonMap(payload),
      options: Options(validateStatus: _allowAnyStatus),
    );

    final result = _unwrapJsonEnvelope(
      label: 'receipt validation',
      response: response,
      mapper: attriaxRevenueReceiptValidationResponseFromJsonEnvelope,
    );
    if (result.response is! AttriaxRevenueReceiptValidationApiResponse) {
      throw const AttriaxTransportInvalidResponseException(
        'Unexpected receipt validation response type.',
      );
    }

    return (result.response as AttriaxRevenueReceiptValidationApiResponse)
        .result;
  }

  Future<AttriaxRevenueUsdConversionResult> convertRevenueToUsd(
    Map<String, Object?> payload,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/sdk/v1/revenue/convert-to-usd',
      data: attriaxNormalizeJsonMap(payload),
      options: Options(validateStatus: _allowAnyStatus),
    );

    final result = _unwrapJsonEnvelope(
      label: 'revenue USD conversion',
      response: response,
      mapper: attriaxRevenueUsdConversionResponseFromJsonEnvelope,
    );
    if (result.response is! AttriaxRevenueUsdConversionApiResponse) {
      throw const AttriaxTransportInvalidResponseException(
        'Unexpected revenue USD conversion response type.',
      );
    }

    return (result.response as AttriaxRevenueUsdConversionApiResponse).result;
  }

  Future<void> eraseGdprData({
    String? projectToken,
    @Deprecated('Use projectToken instead.') String? appToken,
    required String deviceId,
  }) async {
    final resolvedToken = _resolveTransportProjectToken(
      context: 'Attriax GDPR data erasure',
      projectToken: projectToken,
      appToken: appToken,
    );

    final response = await _dio.post<Object?>(
      '/api/sdk/v1/privacy/gdpr/erase',
      data: attriaxNormalizeJsonMap(<String, Object?>{
        'appToken': resolvedToken,
        'deviceId': deviceId,
      }),
      options: Options(validateStatus: _allowAnyStatus),
    );

    final result = _unwrapAckLikeResponse(
      label: 'gdpr data erasure',
      response: response,
    );
    if (result.response is! AttriaxAckResponse) {
      throw const AttriaxTransportInvalidResponseException(
        'Unexpected GDPR data erasure response type.',
      );
    }
  }

  Future<void> registerUninstallToken(Map<String, Object?> payload) async {
    await _sendUninstallTokenRequest(payload);
  }

  Future<AttriaxTransportSuccess> _sendUninstallTokenRequest(
    Map<String, Object?> payload,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/sdk/v1/uninstall-tokens',
      data: attriaxNormalizeJsonMap(payload),
      options: Options(validateStatus: _allowAnyStatus),
    );

    return _unwrapAckLikeResponse(
      label: 'uninstall token registration',
      response: response,
    );
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

  Future<AttriaxTransportSuccess> _sendJsonOpenRequest(
    AttriaxOpenRequest request,
  ) async {
    final response = await _dio.post<Object?>(
      '/api/sdk/v1/open',
      data: attriaxNormalizeJsonMap(request.toQueueBody()),
      options: Options(validateStatus: _allowAnyStatus),
    );

    return _unwrapJsonEnvelope(
      label: 'open',
      response: response,
      mapper: attriaxOpenResponseFromJsonEnvelope,
    );
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
        headers: response.headers,
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
        headers: response.headers,
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

  AttriaxTransportSuccess _unwrapJsonEnvelope({
    required String label,
    required Response<Object?> response,
    required AttriaxApiResponse Function(Map<String, Object?> envelope) mapper,
  }) {
    final statusCode = response.statusCode ?? 0;
    if (!_isSuccessful(statusCode)) {
      throw AttriaxTransportHttpException(
        statusCode: statusCode,
        body: response.data,
      );
    }

    final body = attriaxObjectMap(response.data);
    if (body == null) {
      throw AttriaxTransportInvalidResponseException(
        'Missing $label response body.',
      );
    }

    return AttriaxTransportSuccess(
      statusCode: statusCode,
      response: mapper(body),
    );
  }

  sdk.SdkGdprConsentStatusDto _unwrapGdprConsentResponse({
    required String label,
    required Response<sdk.SdkGdprConsentResponseEnvelopeDto> response,
  }) {
    final statusCode = response.statusCode ?? 0;
    if (!_isSuccessful(statusCode)) {
      throw AttriaxTransportHttpException(
        statusCode: statusCode,
        body: response.data,
        headers: response.headers,
      );
    }

    final envelope = response.data;
    if (envelope == null) {
      throw AttriaxTransportInvalidResponseException(
        'Missing $label response body.',
      );
    }

    return envelope.data;
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
        headers: error.response?.headers,
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

String _attriaxSummarizeErrorBody(Object body) {
  final text = body is String ? body.trim() : body.toString();
  if (text.isEmpty) {
    return '<empty>';
  }

  const maxLength = 500;
  if (text.length <= maxLength) {
    return text;
  }

  return '${text.substring(0, maxLength)}...';
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
        message: _clientExceptionMessage(options, error),
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

  String _clientExceptionMessage(
    RequestOptions options,
    http.ClientException error,
  ) {
    final buffer = StringBuffer(
      'Connection error for ${options.method.toUpperCase()} ${options.uri}: ${error.message}.',
    );

    if (error.message.toLowerCase().contains('failed to fetch')) {
      buffer.write(
        ' In Flutter web this usually means the browser blocked the request '
        'before it reached the API, commonly because the page origin is '
        'missing from the app allowedWebOrigins list or the CORS preflight '
        'OPTIONS request returned 403.',
      );
    }

    return buffer.toString();
  }
}
