//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_event_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkEventDto {
  /// Returns a new [SdkEventDto] instance.
  SdkEventDto({
    required this.appToken,

    this.clientOccurredAt,

    this.deviceId,

    this.deviceIdSource,

    this.eventData,

    required this.eventName,

    this.sessionId,

    this.sessionRelativeTimeMs,
  });

  @JsonKey(name: r'appToken', required: true, includeIfNull: false)
  final String appToken;

  @JsonKey(name: r'clientOccurredAt', required: false, includeIfNull: false)
  final DateTime? clientOccurredAt;

  @JsonKey(name: r'deviceId', required: false, includeIfNull: false)
  final String? deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(name: r'eventData', required: false, includeIfNull: false)
  final Map<String, Object>? eventData;

  @JsonKey(name: r'eventName', required: true, includeIfNull: false)
  final String eventName;

  @JsonKey(name: r'sessionId', required: false, includeIfNull: false)
  final String? sessionId;

  /// Milliseconds since the session started.
  @JsonKey(
    name: r'sessionRelativeTimeMs',
    required: false,
    includeIfNull: false,
  )
  final num? sessionRelativeTimeMs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkEventDto &&
          other.appToken == appToken &&
          other.clientOccurredAt == clientOccurredAt &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.eventData == eventData &&
          other.eventName == eventName &&
          other.sessionId == sessionId &&
          other.sessionRelativeTimeMs == sessionRelativeTimeMs;

  @override
  int get hashCode =>
      appToken.hashCode +
      clientOccurredAt.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      eventData.hashCode +
      eventName.hashCode +
      sessionId.hashCode +
      sessionRelativeTimeMs.hashCode;

  factory SdkEventDto.fromJson(Map<String, dynamic> json) =>
      _$SdkEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
