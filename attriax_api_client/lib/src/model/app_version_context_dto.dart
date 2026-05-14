//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'app_version_context_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppVersionContextDto {
  /// Returns a new [AppVersionContextDto] instance.
  AppVersionContextDto({this.buildNumber, this.packageName, this.version});

  @JsonKey(name: r'buildNumber', required: false, includeIfNull: false)
  final String? buildNumber;

  @JsonKey(name: r'packageName', required: false, includeIfNull: false)
  final String? packageName;

  @JsonKey(name: r'version', required: false, includeIfNull: false)
  final String? version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersionContextDto &&
          other.buildNumber == buildNumber &&
          other.packageName == packageName &&
          other.version == version;

  @override
  int get hashCode =>
      buildNumber.hashCode + packageName.hashCode + version.hashCode;

  factory AppVersionContextDto.fromJson(Map<String, dynamic> json) =>
      _$AppVersionContextDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AppVersionContextDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
