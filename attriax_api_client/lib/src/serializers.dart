//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:attriax_api_client/src/date_serializer.dart';
import 'package:attriax_api_client/src/model/date.dart';

import 'package:attriax_api_client/src/model/app_user_uninstall_token_provider.dart';
import 'package:attriax_api_client/src/model/app_version_context_dto.dart';
import 'package:attriax_api_client/src/model/attribution_type.dart';
import 'package:attriax_api_client/src/model/deep_link_resolution_status.dart';
import 'package:attriax_api_client/src/model/device_context_dto.dart';
import 'package:attriax_api_client/src/model/platform.dart';
import 'package:attriax_api_client/src/model/sdk_acknowledge_response_dto.dart';
import 'package:attriax_api_client/src/model/sdk_acknowledge_response_envelope_dto.dart';
import 'package:attriax_api_client/src/model/sdk_batch_item_kind.dart';
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
import 'package:attriax_api_client/src/model/sdk_session_dto.dart';
import 'package:attriax_api_client/src/model/sdk_session_lifecycle_kind.dart';
import 'package:attriax_api_client/src/model/sdk_user_dto.dart';
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
import 'package:attriax_api_client/src/model/sdk_v1_revenue_receipt_validate_dto.dart';
import 'package:attriax_api_client/src/model/sdk_version_context_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  AppUserUninstallTokenProvider,
  AppVersionContextDto,
  AttributionType,
  DeepLinkResolutionStatus,
  DeviceContextDto,
  Platform,
  SdkAcknowledgeResponseDto,
  SdkAcknowledgeResponseEnvelopeDto,
  SdkBatchItemKind,
  SdkCrashDto,
  SdkCreateDynamicLinkDto,
  SdkCreateDynamicLinkResponseDto,
  SdkCreateDynamicLinkResponseEnvelopeDto,
  SdkDynamicLinkRecordDto,
  SdkEventDto,
  SdkInstallReferrerResultDto,
  SdkJsonDeepLinkDto,
  SdkRegisterUninstallTokenDto,
  SdkRevenueReceiptValidateResponseDto,
  SdkRevenueReceiptValidateResponseEnvelopeDto,
  SdkSessionDto,
  SdkSessionLifecycleKind,
  SdkUserDto,
  SdkV1BatchDto,
  SdkV1BatchItemDto,
  SdkV1BatchResponseDto,
  SdkV1BatchResponseEnvelopeDto,
  SdkV1DeepLinkResolveDto,
  SdkV1DeepLinkResolveResponseDto,
  SdkV1DeepLinkResolveResponseEnvelopeDto,
  SdkV1OpenDto,
  SdkV1OpenResponseDto,
  SdkV1OpenResponseEnvelopeDto,
  SdkV1RevenueReceiptValidateDto,
  SdkVersionContextDto,
])
Serializers serializers =
    (_$serializers.toBuilder()
          ..add(const OneOfSerializer())
          ..add(const AnyOfSerializer())
          ..add(const DateSerializer())
          ..add(Iso8601DateTimeSerializer()))
        .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
