import 'package:attriax_api_client/src/model/app_version_context_dto.dart';
import 'package:attriax_api_client/src/model/device_context_dto.dart';
import 'package:attriax_api_client/src/model/sdk_acknowledge_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_acknowledge_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_browser_action_dto.dart';
import 'package:attriax_api_client/src/model/sdk_crash_dto.dart';
import 'package:attriax_api_client/src/model/sdk_create_dynamic_link_dto.dart';
import 'package:attriax_api_client/src/model/sdk_create_dynamic_link_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_create_dynamic_link_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_dynamic_link_record_dto.dart';
import 'package:attriax_api_client/src/model/sdk_event_dto.dart';
import 'package:attriax_api_client/src/model/sdk_install_referrer_result_dto.dart';
import 'package:attriax_api_client/src/model/sdk_json_deep_link_dto.dart';
import 'package:attriax_api_client/src/model/sdk_register_uninstall_token_dto.dart';
import 'package:attriax_api_client/src/model/sdk_revenue_receipt_validate_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_revenue_receipt_validate_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_revenue_usd_conversion_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_revenue_usd_conversion_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_session_dto.dart';
import 'package:attriax_api_client/src/model/sdk_user_dto.dart';
import 'package:attriax_api_client/src/model/sdk_utm_payload_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_batch_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_batch_item_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_batch_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_batch_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_deep_link_resolve_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_deep_link_resolve_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_deep_link_resolve_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_open_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_open_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_open_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_revenue_convert_to_usd_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_revenue_receipt_validate_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_coarse_window_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_coarse_window_event_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_condition_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_event_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_runtime_configuration_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_schema_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_window1_dto.dart';
import 'package:attriax_api_client/src/model/sdk_v1_skan_window1_group_dto.dart';
import 'package:attriax_api_client/src/model/sdk_version_context_dto.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AppUserUninstallTokenProvider':
    case 'AppVersionContextDto':
      return AppVersionContextDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AttributionType':
    case 'DeepLinkResolutionStatus':
    case 'DeviceContextDto':
      return DeviceContextDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Platform':
    case 'RouteUrlOpenMode':
    case 'SdkAcknowledgeResponseDto':
      return SdkAcknowledgeResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkAcknowledgeResponseEnvelopeDto':
      return SdkAcknowledgeResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkBatchItemKind':
    case 'SdkBrowserActionDto':
      return SdkBrowserActionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkCrashDto':
      return SdkCrashDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SdkCreateDynamicLinkDto':
      return SdkCreateDynamicLinkDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkCreateDynamicLinkResponseDto':
      return SdkCreateDynamicLinkResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkCreateDynamicLinkResponseEnvelopeDto':
      return SdkCreateDynamicLinkResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkDynamicLinkRecordDto':
      return SdkDynamicLinkRecordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkEventDto':
      return SdkEventDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SdkInstallReferrerResultDto':
      return SdkInstallReferrerResultDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkInstallState':
    case 'SdkJsonDeepLinkDto':
      return SdkJsonDeepLinkDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkRegisterUninstallTokenDto':
      return SdkRegisterUninstallTokenDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkRevenueReceiptValidateResponseDto':
      return SdkRevenueReceiptValidateResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkRevenueReceiptValidateResponseEnvelopeDto':
      return SdkRevenueReceiptValidateResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkRevenueUsdConversionResponseDto':
      return SdkRevenueUsdConversionResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkRevenueUsdConversionResponseEnvelopeDto':
      return SdkRevenueUsdConversionResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkSessionDto':
      return SdkSessionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkSessionLifecycleKind':
    case 'SdkUserDto':
      return SdkUserDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SdkUtmPayloadDto':
      return SdkUtmPayloadDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1BatchDto':
      return SdkV1BatchDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1BatchItemDto':
      return SdkV1BatchItemDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1BatchResponseDto':
      return SdkV1BatchResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1BatchResponseEnvelopeDto':
      return SdkV1BatchResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1DeepLinkResolveDto':
      return SdkV1DeepLinkResolveDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1DeepLinkResolveResponseDto':
      return SdkV1DeepLinkResolveResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1DeepLinkResolveResponseEnvelopeDto':
      return SdkV1DeepLinkResolveResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1OpenDto':
      return SdkV1OpenDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SdkV1OpenResponseDto':
      return SdkV1OpenResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1OpenResponseEnvelopeDto':
      return SdkV1OpenResponseEnvelopeDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1RevenueConvertToUsdDto':
      return SdkV1RevenueConvertToUsdDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1RevenueReceiptValidateDto':
      return SdkV1RevenueReceiptValidateDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1SkanCoarseValue':
    case 'SdkV1SkanCoarseWindowDto':
      return SdkV1SkanCoarseWindowDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1SkanCoarseWindowEventDto':
      return SdkV1SkanCoarseWindowEventDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1SkanConditionDto':
      return SdkV1SkanConditionDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1SkanEventDto':
      return SdkV1SkanEventDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1SkanRuleOperator':
    case 'SdkV1SkanRuntimeConfigurationDto':
      return SdkV1SkanRuntimeConfigurationDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SdkV1SkanSchemaDto':
      return SdkV1SkanSchemaDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1SkanWindow1Dto':
      return SdkV1SkanWindow1Dto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkV1SkanWindow1GroupDto':
      return SdkV1SkanWindow1GroupDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SdkVersionContextDto':
      return SdkVersionContextDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
