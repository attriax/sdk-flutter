// ignore_for_file: deprecated_member_use

part of '../../attriax_api_models.dart';

String attriaxApiRequestLabel(AttriaxApiRequest request) => request.label;

bool attriaxCanBatchRequest(AttriaxApiRequest request) => switch (request) {
  AttriaxTrackEventRequest(:final payload) => payload.deviceId != null,
  AttriaxTrackSessionRequest(:final payload) => payload.deviceId != null,
  AttriaxUserRequest() => true,
  _ => false,
};

String _attriaxResolveCompatibleToken({
  required String context,
  String? projectToken,
  String? appToken,
}) {
  final normalizedProjectToken = attriaxStringValue(projectToken)?.trim();
  final normalizedAppToken = attriaxStringValue(appToken)?.trim();

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

final class AttriaxBatchRequestIdentity {
  const AttriaxBatchRequestIdentity({
    required this.appToken,
    required this.deviceId,
    this.deviceIdSource,
  });

  final String appToken;
  final String deviceId;
  final String? deviceIdSource;
}

AttriaxBatchRequestIdentity attriaxBatchRequestIdentity(
  AttriaxApiRequest request,
) {
  switch (request) {
    case AttriaxTrackEventRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: _attriaxResolveCompatibleToken(
          context: 'Attriax event batch identity',
          projectToken: payload.projectToken,
          appToken: payload.appToken,
        ),
        deviceId: payload.deviceId!,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxTrackSessionRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: _attriaxResolveCompatibleToken(
          context: 'Attriax session batch identity',
          appToken: payload.appToken,
        ),
        deviceId: payload.deviceId!,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxUserRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        appToken: _attriaxResolveCompatibleToken(
          context: 'Attriax user batch identity',
          projectToken: payload.projectToken,
          appToken: payload.appToken,
        ),
        deviceId: payload.deviceId,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    default:
      throw ArgumentError(
        'Unsupported Attriax batch request kind: ${request.kindName}',
      );
  }
}

bool attriaxCanShareBatchRequest(
  AttriaxApiRequest left,
  AttriaxApiRequest right,
) {
  if (!attriaxCanBatchRequest(left) || !attriaxCanBatchRequest(right)) {
    return false;
  }

  final leftIdentity = attriaxBatchRequestIdentity(left);
  final rightIdentity = attriaxBatchRequestIdentity(right);
  return leftIdentity.appToken == rightIdentity.appToken &&
      leftIdentity.deviceId == rightIdentity.deviceId &&
      leftIdentity.deviceIdSource == rightIdentity.deviceIdSource;
}

Map<String, Object?> attriaxBatchBody(AttriaxApiRequest request) {
  if (!attriaxCanBatchRequest(request)) {
    throw ArgumentError(
      'Unsupported Attriax batch request kind: ${request.kindName}',
    );
  }

  final body = Map<String, Object?>.from(request.toQueueBody())
    ..remove('appToken')
    ..remove('projectToken')
    ..remove('deviceId')
    ..remove('deviceIdSource');
  return body;
}

String attriaxBatchRequestId(String queuedRequestId) =>
    'batch_$queuedRequestId';

String attriaxBatchKindName(AttriaxApiRequest request) => switch (request) {
  AttriaxTrackEventRequest() => 'event',
  AttriaxTrackSessionRequest() => 'session',
  AttriaxUserRequest() => 'user',
  _ => throw ArgumentError(
    'Unsupported Attriax batch request kind: ${request.kindName}',
  ),
};
