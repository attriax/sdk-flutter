//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sdk_user_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkUserDto {
  /// Returns a new [SdkUserDto] instance.
  SdkUserDto({
    this.appToken,

    this.clearAllProperties,

    this.clearExternalUser,

    this.clearPropertyKeys,

    required this.deviceId,

    this.deviceIdSource,

    this.externalUserId,

    this.externalUserName,

    this.projectToken,

    this.properties,
  });

  /// Deprecated alias for projectToken kept for released SDK compatibility.
  @Deprecated('appToken has been deprecated')
  @JsonKey(name: r'appToken', required: false, includeIfNull: false)
  final String? appToken;

  /// Clears every stored user property before applying this request.
  @JsonKey(name: r'clearAllProperties', required: false, includeIfNull: false)
  final bool? clearAllProperties;

  /// Clears the stored external user id and name for future events.
  @JsonKey(name: r'clearExternalUser', required: false, includeIfNull: false)
  final bool? clearExternalUser;

  /// Specific stored user-property keys to clear.
  @JsonKey(name: r'clearPropertyKeys', required: false, includeIfNull: false)
  final List<String>? clearPropertyKeys;

  @JsonKey(name: r'deviceId', required: true, includeIfNull: false)
  final String deviceId;

  @JsonKey(name: r'deviceIdSource', required: false, includeIfNull: false)
  final String? deviceIdSource;

  @JsonKey(name: r'externalUserId', required: false, includeIfNull: false)
  final String? externalUserId;

  @JsonKey(name: r'externalUserName', required: false, includeIfNull: false)
  final String? externalUserName;

  /// Attriax project token that scopes the SDK request.
  @JsonKey(name: r'projectToken', required: false, includeIfNull: false)
  final String? projectToken;

  /// User properties merged into future event payloads until they are cleared or replaced.
  @JsonKey(name: r'properties', required: false, includeIfNull: false)
  final Map<String, Object>? properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkUserDto &&
          other.appToken == appToken &&
          other.clearAllProperties == clearAllProperties &&
          other.clearExternalUser == clearExternalUser &&
          other.clearPropertyKeys == clearPropertyKeys &&
          other.deviceId == deviceId &&
          other.deviceIdSource == deviceIdSource &&
          other.externalUserId == externalUserId &&
          other.externalUserName == externalUserName &&
          other.projectToken == projectToken &&
          other.properties == properties;

  @override
  int get hashCode =>
      appToken.hashCode +
      clearAllProperties.hashCode +
      clearExternalUser.hashCode +
      clearPropertyKeys.hashCode +
      deviceId.hashCode +
      deviceIdSource.hashCode +
      externalUserId.hashCode +
      externalUserName.hashCode +
      projectToken.hashCode +
      properties.hashCode;

  factory SdkUserDto.fromJson(Map<String, dynamic> json) =>
      _$SdkUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkUserDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
