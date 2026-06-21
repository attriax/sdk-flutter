//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/notification_event_source.dart';
import 'package:attriax_api_client/src/model/notification_event_type.dart';
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_notification_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkNotificationDto {
  /// Returns a new [SdkNotificationDto] instance.
  SdkNotificationDto({
    this.appToken,

    this.campaignId,

    this.deviceId,

    this.deviceIdSource,

    this.linkId,

    this.metadata,

    required this.notificationId,

    this.occurredAt,

    required this.platform,

    this.projectToken,

    this.sessionId,

    this.source_,

    this.title,

    required this.type,
  });

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  /// Optional reference to an existing Attriax campaign this notification relates to.
  @JsonKey(name: r'campaignId', required: false, includeIfNull: false)
  final String? campaignId;

  @JsonKey(name: r'deviceId', required: false, includeIfNull: false)
  final String? deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  /// Optional reference to an existing Attriax tracked link this notification relates to.
  @JsonKey(name: r'linkId', required: false, includeIfNull: false)
  final String? linkId;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  /// Client-provided notification identifier. Combined with the project and type it forms the idempotency key so retries do not double-count.
  @JsonKey(name: r'notificationId', required: true, includeIfNull: false)
  final String notificationId;

  @JsonKey(name: r'occurredAt', required: false, includeIfNull: false)
  final DateTime? occurredAt;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final Platform platform;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  @JsonKey(name: r'sessionId', required: false, includeIfNull: false)
  final String? sessionId;

  /// Delivery channel the notification arrived through.
  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final NotificationEventSource? source_;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  /// Lifecycle stage: received, opened, or dismissed.
  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final NotificationEventType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkNotificationDto &&
          other.appToken == appToken &&
          other.campaignId == campaignId &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.linkId == linkId &&
          other.metadata == metadata &&
          other.notificationId == notificationId &&
          other.occurredAt == occurredAt &&
          other.platform == platform &&
          other.projectToken == projectToken &&
          other.sessionId == sessionId &&
          other.source_ == source_ &&
          other.title == title &&
          other.type == type;

  @override
  int get hashCode =>
      appToken.hashCode +
      campaignId.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      linkId.hashCode +
      metadata.hashCode +
      notificationId.hashCode +
      occurredAt.hashCode +
      platform.hashCode +
      projectToken.hashCode +
      sessionId.hashCode +
      source_.hashCode +
      title.hashCode +
      type.hashCode;

  factory SdkNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$SdkNotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkNotificationDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
