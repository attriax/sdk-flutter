//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_event_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_window1_group_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanWindow1GroupDto {
  /// Returns a new [SdkV1SkanWindow1GroupDto] instance.
  SdkV1SkanWindow1GroupDto({
    required this.bitCount,

    this.displayName,

    required this.events,

    required this.id,

    required this.startBit,
  });

  // minimum: 1
  // maximum: 6
  @JsonKey(name: r'bitCount', required: true, includeIfNull: false)
  final num bitCount;

  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final Object? displayName;

  @JsonKey(name: r'events', required: true, includeIfNull: false)
  final List<SdkV1SkanEventDto> events;

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  // minimum: 0
  // maximum: 5
  @JsonKey(name: r'startBit', required: true, includeIfNull: false)
  final num startBit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanWindow1GroupDto &&
          other.bitCount == bitCount &&
          other.displayName == displayName &&
          other.events == events &&
          other.id == id &&
          other.startBit == startBit;

  @override
  int get hashCode =>
      bitCount.hashCode +
      (displayName == null ? 0 : displayName.hashCode) +
      events.hashCode +
      id.hashCode +
      startBit.hashCode;

  factory SdkV1SkanWindow1GroupDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1SkanWindow1GroupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1SkanWindow1GroupDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
