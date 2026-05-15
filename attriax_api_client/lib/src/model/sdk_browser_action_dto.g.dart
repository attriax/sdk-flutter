// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_browser_action_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkBrowserActionDto _$SdkBrowserActionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SdkBrowserActionDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['openMode', 'url']);
      final val = SdkBrowserActionDto(
        openMode: $checkedConvert(
          'openMode',
          (v) => $enumDecode(_$RouteUrlOpenModeEnumMap, v),
        ),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SdkBrowserActionDtoToJson(
  SdkBrowserActionDto instance,
) => <String, dynamic>{
  'openMode': _$RouteUrlOpenModeEnumMap[instance.openMode]!,
  'url': instance.url,
};

const _$RouteUrlOpenModeEnumMap = {
  RouteUrlOpenMode.inApp: 'in_app',
  RouteUrlOpenMode.external_: 'external',
};
