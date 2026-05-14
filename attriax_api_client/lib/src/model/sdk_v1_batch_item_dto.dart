//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:attriax_api_client/src/model/sdk_batch_item_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sdk_v1_batch_item_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SdkV1BatchItemDto {
  /// Returns a new [SdkV1BatchItemDto] instance.
  SdkV1BatchItemDto({required this.body, required this.kind});

  /// SDK request payload for the selected item kind.
  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final Map<String, Object> body;

  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final SdkBatchItemKind kind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SdkV1BatchItemDto && other.body == body && other.kind == kind;

  @override
  int get hashCode => body.hashCode + kind.hashCode;

  factory SdkV1BatchItemDto.fromJson(Map<String, dynamic> json) =>
      _$SdkV1BatchItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SdkV1BatchItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
