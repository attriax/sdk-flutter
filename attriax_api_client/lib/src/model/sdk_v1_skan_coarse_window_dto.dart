//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_coarse_window_event_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_coarse_window_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanCoarseWindowDto {
  /// Returns a new [SdkV1SkanCoarseWindowDto] instance.
  SdkV1SkanCoarseWindowDto({required this.events});

  @JsonKey(name: r'events', required: true, includeIfNull: false)
  final List<SdkV1SkanCoarseWindowEventDto> events;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanCoarseWindowDto && other.events == events;

  @override
  int get hashCode => events.hashCode;

  factory SdkV1SkanCoarseWindowDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1SkanCoarseWindowDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1SkanCoarseWindowDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
