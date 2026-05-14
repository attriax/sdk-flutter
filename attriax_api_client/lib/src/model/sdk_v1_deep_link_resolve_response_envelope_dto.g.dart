// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sdk_v1_deep_link_resolve_response_envelope_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SdkV1DeepLinkResolveResponseEnvelopeDto
_$SdkV1DeepLinkResolveResponseEnvelopeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SdkV1DeepLinkResolveResponseEnvelopeDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['data', 'success', 'timestamp']);
  final val = SdkV1DeepLinkResolveResponseEnvelopeDto(
    data: $checkedConvert(
      'data',
      (v) =>
          SdkV1DeepLinkResolveResponseDto.fromJson(v as Map<String, dynamic>),
    ),
    success: $checkedConvert('success', (v) => v as bool),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SdkV1DeepLinkResolveResponseEnvelopeDtoToJson(
  SdkV1DeepLinkResolveResponseEnvelopeDto instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'success': instance.success,
  'timestamp': instance.timestamp.toIso8601String(),
};
