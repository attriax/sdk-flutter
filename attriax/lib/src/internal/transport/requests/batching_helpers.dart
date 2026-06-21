part of '../../attriax_api_models.dart';

String attriaxApiRequestLabel(AttriaxApiRequest request) => request.label;

bool attriaxCanBatchRequest(AttriaxApiRequest request) => switch (request) {
  AttriaxTrackEventRequest(:final payload) => payload.deviceId != null,
  AttriaxTrackSessionRequest(:final payload) => payload.deviceId != null,
  AttriaxUserRequest() => true,
  _ => false,
};

final class AttriaxBatchRequestIdentity {
  const AttriaxBatchRequestIdentity({
    required this.projectToken,
    required this.deviceId,
    this.deviceIdSource,
  });

  final String projectToken;
  final String deviceId;
  final String? deviceIdSource;
}

AttriaxBatchRequestIdentity attriaxBatchRequestIdentity(
  AttriaxApiRequest request,
) {
  switch (request) {
    case AttriaxTrackEventRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        projectToken: payload.projectToken!,
        deviceId: payload.deviceId!,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxTrackSessionRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        projectToken: payload.projectToken,
        deviceId: payload.deviceId!,
        deviceIdSource: attriaxStringValue(payload.deviceIdSource),
      );
    case AttriaxUserRequest(:final payload):
      return AttriaxBatchRequestIdentity(
        projectToken: payload.projectToken!,
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
  return leftIdentity.projectToken == rightIdentity.projectToken &&
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
