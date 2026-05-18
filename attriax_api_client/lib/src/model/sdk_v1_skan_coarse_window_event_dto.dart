//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_coarse_value.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_condition_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_coarse_window_event_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanCoarseWindowEventDto {
  /// Returns a new [SdkV1SkanCoarseWindowEventDto] instance.
  SdkV1SkanCoarseWindowEventDto({
    this.coarseValue,

    required this.conditions,

    this.displayName,

    required this.eventName,

    required this.id,

    this.lockWindow,
  });

  @JsonKey(name: r'coarseValue', required: false, includeIfNull: false)
  final SdkV1SkanCoarseValue? coarseValue;

  @JsonKey(name: r'conditions', required: true, includeIfNull: false)
  final List<SdkV1SkanConditionDto> conditions;

  @JsonKey(name: r'displayName', required: false, includeIfNull: false)
  final Object? displayName;

  @JsonKey(name: r'eventName', required: true, includeIfNull: false)
  final String eventName;

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'lockWindow', required: false, includeIfNull: false)
  final bool? lockWindow;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanCoarseWindowEventDto &&
          other.coarseValue == coarseValue &&
          other.conditions == conditions &&
          other.displayName == displayName &&
          other.eventName == eventName &&
          other.id == id &&
          other.lockWindow == lockWindow;

  @override
  int get hashCode =>
      (coarseValue == null ? 0 : coarseValue.hashCode) +
      conditions.hashCode +
      (displayName == null ? 0 : displayName.hashCode) +
      eventName.hashCode +
      id.hashCode +
      lockWindow.hashCode;

  factory SdkV1SkanCoarseWindowEventDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1SkanCoarseWindowEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1SkanCoarseWindowEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
