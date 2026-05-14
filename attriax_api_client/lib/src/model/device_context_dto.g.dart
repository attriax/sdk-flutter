// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_context_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceContextDto _$DeviceContextDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeviceContextDto', json, ($checkedConvert) {
  final val = DeviceContextDto(
    advertisingId: $checkedConvert('advertisingId', (v) => v as String?),
    androidId: $checkedConvert('androidId', (v) => v as String?),
    brand: $checkedConvert('brand', (v) => v as String?),
    colorDepth: $checkedConvert('colorDepth', (v) => v as num?),
    devicePixelRatio: $checkedConvert('devicePixelRatio', (v) => v as num?),
    hardware: $checkedConvert('hardware', (v) => v as String?),
    isPhysicalDevice: $checkedConvert('isPhysicalDevice', (v) => v as bool?),
    language: $checkedConvert('language', (v) => v as String?),
    manufacturer: $checkedConvert('manufacturer', (v) => v as String?),
    metadata: $checkedConvert(
      'metadata',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    model: $checkedConvert('model', (v) => v as String?),
    name: $checkedConvert('name', (v) => v as String?),
    osVersion: $checkedConvert('osVersion', (v) => v as String?),
    screenHeight: $checkedConvert('screenHeight', (v) => v as num?),
    screenResolution: $checkedConvert('screenResolution', (v) => v as String?),
    screenWidth: $checkedConvert('screenWidth', (v) => v as num?),
    supportedAbis: $checkedConvert(
      'supportedAbis',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    timezone: $checkedConvert('timezone', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$DeviceContextDtoToJson(DeviceContextDto instance) =>
    <String, dynamic>{
      'advertisingId': ?instance.advertisingId,
      'androidId': ?instance.androidId,
      'brand': ?instance.brand,
      'colorDepth': ?instance.colorDepth,
      'devicePixelRatio': ?instance.devicePixelRatio,
      'hardware': ?instance.hardware,
      'isPhysicalDevice': ?instance.isPhysicalDevice,
      'language': ?instance.language,
      'manufacturer': ?instance.manufacturer,
      'metadata': ?instance.metadata,
      'model': ?instance.model,
      'name': ?instance.name,
      'osVersion': ?instance.osVersion,
      'screenHeight': ?instance.screenHeight,
      'screenResolution': ?instance.screenResolution,
      'screenWidth': ?instance.screenWidth,
      'supportedAbis': ?instance.supportedAbis,
      'timezone': ?instance.timezone,
    };
