//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'device_context_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceContextDto {
  /// Returns a new [DeviceContextDto] instance.
  DeviceContextDto({
    this.advertisingId,

    this.androidId,

    this.brand,

    this.colorDepth,

    this.devicePixelRatio,

    this.hardware,

    this.isPhysicalDevice,

    this.language,

    this.manufacturer,

    this.metadata,

    this.model,

    this.name,

    this.osVersion,

    this.screenHeight,

    this.screenResolution,

    this.screenWidth,

    this.supportedAbis,

    this.timezone,
  });

  @JsonKey(name: r'advertisingId', required: false, includeIfNull: false)
  final String? advertisingId;

  @JsonKey(name: r'androidId', required: false, includeIfNull: false)
  final String? androidId;

  @JsonKey(name: r'brand', required: false, includeIfNull: false)
  final String? brand;

  @JsonKey(name: r'colorDepth', required: false, includeIfNull: false)
  final num? colorDepth;

  @JsonKey(name: r'devicePixelRatio', required: false, includeIfNull: false)
  final num? devicePixelRatio;

  @JsonKey(name: r'hardware', required: false, includeIfNull: false)
  final String? hardware;

  @JsonKey(name: r'isPhysicalDevice', required: false, includeIfNull: false)
  final bool? isPhysicalDevice;

  @JsonKey(name: r'language', required: false, includeIfNull: false)
  final String? language;

  @JsonKey(name: r'manufacturer', required: false, includeIfNull: false)
  final String? manufacturer;

  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Map<String, Object>? metadata;

  @JsonKey(name: r'model', required: false, includeIfNull: false)
  final String? model;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'osVersion', required: false, includeIfNull: false)
  final String? osVersion;

  @JsonKey(name: r'screenHeight', required: false, includeIfNull: false)
  final num? screenHeight;

  @JsonKey(name: r'screenResolution', required: false, includeIfNull: false)
  final String? screenResolution;

  @JsonKey(name: r'screenWidth', required: false, includeIfNull: false)
  final num? screenWidth;

  @JsonKey(name: r'supportedAbis', required: false, includeIfNull: false)
  final List<String>? supportedAbis;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceContextDto &&
          other.advertisingId == advertisingId &&
          other.androidId == androidId &&
          other.brand == brand &&
          other.colorDepth == colorDepth &&
          other.devicePixelRatio == devicePixelRatio &&
          other.hardware == hardware &&
          other.isPhysicalDevice == isPhysicalDevice &&
          other.language == language &&
          other.manufacturer == manufacturer &&
          other.metadata == metadata &&
          other.model == model &&
          other.name == name &&
          other.osVersion == osVersion &&
          other.screenHeight == screenHeight &&
          other.screenResolution == screenResolution &&
          other.screenWidth == screenWidth &&
          other.supportedAbis == supportedAbis &&
          other.timezone == timezone;

  @override
  int get hashCode =>
      advertisingId.hashCode +
      androidId.hashCode +
      brand.hashCode +
      colorDepth.hashCode +
      devicePixelRatio.hashCode +
      hardware.hashCode +
      isPhysicalDevice.hashCode +
      language.hashCode +
      manufacturer.hashCode +
      metadata.hashCode +
      model.hashCode +
      name.hashCode +
      osVersion.hashCode +
      screenHeight.hashCode +
      screenResolution.hashCode +
      screenWidth.hashCode +
      supportedAbis.hashCode +
      timezone.hashCode;

  factory DeviceContextDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceContextDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceContextDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
