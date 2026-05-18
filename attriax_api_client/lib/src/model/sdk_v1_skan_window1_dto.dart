//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_v1_skan_window1_group_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_skan_window1_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1SkanWindow1Dto {
  /// Returns a new [SdkV1SkanWindow1Dto] instance.
  SdkV1SkanWindow1Dto({required this.groups});

  @JsonKey(name: r'groups', required: true, includeIfNull: false)
  final List<SdkV1SkanWindow1GroupDto> groups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1SkanWindow1Dto && other.groups == groups;

  @override
  int get hashCode => groups.hashCode;

  factory SdkV1SkanWindow1Dto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1SkanWindow1DtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1SkanWindow1DtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
