// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attriax_command_args.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AttriaxInitializeArgsToJson(
  AttriaxInitializeArgs instance,
) => <String, dynamic>{'config': _configToJson(instance.config)};

Map<String, dynamic> _$AttriaxRecordEventArgsToJson(
  AttriaxRecordEventArgs instance,
) => <String, dynamic>{
  'name': instance.name,
  'eventData': ?instance.eventData,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordPageViewArgsToJson(
  AttriaxRecordPageViewArgs instance,
) => <String, dynamic>{
  'pageName': instance.pageName,
  'pageClass': ?instance.pageClass,
  'pageTitle': ?instance.pageTitle,
  'previousPageName': ?instance.previousPageName,
  'parameters': ?instance.parameters,
  'source': instance.source,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordPurchaseArgsToJson(
  AttriaxRecordPurchaseArgs instance,
) => <String, dynamic>{
  'revenue': instance.revenue,
  'currency': instance.currency,
  'revenueInMicros': instance.revenueInMicros,
  'purchaseType': ?instance.purchaseType,
  'productId': ?instance.productId,
  'transactionId': ?instance.transactionId,
  'originalTransactionId': ?instance.originalTransactionId,
  'validationProvider': ?instance.validationProvider,
  'validationEnvironment': ?instance.validationEnvironment,
  'purchaseToken': ?instance.purchaseToken,
  'receiptData': ?instance.receiptData,
  'signedPayload': ?instance.signedPayload,
  'receiptSignature': ?instance.receiptSignature,
  'isRenewal': ?instance.isRenewal,
  'quantity': instance.quantity,
  'store': ?instance.store,
  'packageName': ?instance.packageName,
  'voided': ?instance.voided,
  'test': ?instance.test,
  'validationId': ?instance.validationId,
  'metadata': ?instance.metadata,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordRefundArgsToJson(
  AttriaxRecordRefundArgs instance,
) => <String, dynamic>{
  'revenue': instance.revenue,
  'currency': instance.currency,
  'revenueInMicros': instance.revenueInMicros,
  'purchaseType': ?instance.purchaseType,
  'productId': ?instance.productId,
  'transactionId': ?instance.transactionId,
  'originalTransactionId': ?instance.originalTransactionId,
  'quantity': instance.quantity,
  'store': ?instance.store,
  'packageName': ?instance.packageName,
  'voided': ?instance.voided,
  'test': ?instance.test,
  'reason': ?instance.reason,
  'metadata': ?instance.metadata,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordAdRevenueArgsToJson(
  AttriaxRecordAdRevenueArgs instance,
) => <String, dynamic>{
  'revenue': instance.revenue,
  'currency': instance.currency,
  'revenueInMicros': instance.revenueInMicros,
  'adNetwork': ?instance.adNetwork,
  'adFormat': ?instance.adFormat,
  'adType': ?instance.adType,
  'adPlacement': ?instance.adPlacement,
  'test': ?instance.test,
  'metadata': ?instance.metadata,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordAdEventArgsToJson(
  AttriaxRecordAdEventArgs instance,
) => <String, dynamic>{
  'eventName': instance.eventName,
  'adNetwork': ?instance.adNetwork,
  'mediationNetwork': ?instance.mediationNetwork,
  'adUnitId': ?instance.adUnitId,
  'adPlacement': ?instance.adPlacement,
  'adFormat': ?instance.adFormat,
  'adType': ?instance.adType,
  'failureReason': ?instance.failureReason,
  'loadLatencyMs': ?instance.loadLatencyMs,
  'rewardType': ?instance.rewardType,
  'rewardAmount': ?instance.rewardAmount,
  'test': ?instance.test,
  'metadata': ?instance.metadata,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordNotificationArgsToJson(
  AttriaxRecordNotificationArgs instance,
) => <String, dynamic>{
  'type': instance.type,
  'notificationId': instance.notificationId,
  'linkId': ?instance.linkId,
  'campaignId': ?instance.campaignId,
  'title': ?instance.title,
  'source': ?instance.source,
  'payload': ?instance.payload,
  'metadata': ?instance.metadata,
  'flushImmediately': instance.flushImmediately,
};

Map<String, dynamic> _$AttriaxRecordErrorArgsToJson(
  AttriaxRecordErrorArgs instance,
) => <String, dynamic>{
  'message': instance.message,
  'exceptionType': instance.exceptionType,
  'stackTrace': ?instance.stackTrace,
  'fatal': instance.fatal,
  'source': instance.source,
  'reason': ?instance.reason,
  'metadata': ?instance.metadata,
};

Map<String, dynamic> _$AttriaxSetUserArgsToJson(AttriaxSetUserArgs instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': ?instance.userName,
    };

Map<String, dynamic> _$AttriaxSetUserPropertyArgsToJson(
  AttriaxSetUserPropertyArgs instance,
) => <String, dynamic>{'name': instance.name, 'value': instance.value};

Map<String, dynamic> _$AttriaxSetUserPropertiesArgsToJson(
  AttriaxSetUserPropertiesArgs instance,
) => <String, dynamic>{'properties': instance.properties};

Map<String, dynamic> _$AttriaxClearUserPropertiesArgsToJson(
  AttriaxClearUserPropertiesArgs instance,
) => <String, dynamic>{'propertyNames': ?instance.propertyNames};

Map<String, dynamic> _$AttriaxRegisterPushTokenArgsToJson(
  AttriaxRegisterPushTokenArgs instance,
) => <String, dynamic>{
  'provider': _pushTokenProviderToWire(instance.provider),
  'token': instance.token,
  'metadata': ?instance.metadata,
};

Map<String, dynamic> _$AttriaxHandleIncomingLinkArgsToJson(
  AttriaxHandleIncomingLinkArgs instance,
) => <String, dynamic>{
  'uri': instance.uri,
  'isInitialLink': instance.isInitialLink,
};

Map<String, dynamic> _$AttriaxRecordDeepLinkArgsToJson(
  AttriaxRecordDeepLinkArgs instance,
) => <String, dynamic>{
  'uri': instance.uri,
  'metadata': ?instance.metadata,
  'source': instance.source,
};

Map<String, dynamic> _$AttriaxWaitForDeepLinkResolutionArgsToJson(
  AttriaxWaitForDeepLinkResolutionArgs instance,
) => <String, dynamic>{'rawEvent': _rawDeepLinkEventToJson(instance.rawEvent)};

Map<String, dynamic> _$AttriaxCreateDynamicLinkArgsToJson(
  AttriaxCreateDynamicLinkArgs instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'destinationUrl': ?instance.destinationUrl,
  'group': ?instance.group,
  'prefix': ?instance.prefix,
  'socialPreview': ?_socialPreviewArgsToJson(instance.socialPreview),
  'utms': ?_utmsArgsToJson(instance.utms),
  'redirects': ?_redirectsArgsToJson(instance.redirects),
  'data': ?instance.data,
};

Map<String, dynamic> _$AttriaxDynamicLinkSocialPreviewArgsToJson(
  AttriaxDynamicLinkSocialPreviewArgs instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'description': ?instance.description,
};

Map<String, dynamic> _$AttriaxDynamicLinkUtmsArgsToJson(
  AttriaxDynamicLinkUtmsArgs instance,
) => <String, dynamic>{
  'source': ?instance.source,
  'medium': ?instance.medium,
  'campaign': ?instance.campaign,
  'term': ?instance.term,
  'content': ?instance.content,
};

Map<String, dynamic> _$AttriaxDynamicLinkRedirectsArgsToJson(
  AttriaxDynamicLinkRedirectsArgs instance,
) => <String, dynamic>{'ios': ?instance.ios, 'android': ?instance.android};

Map<String, dynamic> _$AttriaxValidateReceiptArgsToJson(
  AttriaxValidateReceiptArgs instance,
) => <String, dynamic>{
  'receipt': instance.receipt,
  'test': instance.test,
  'provider': ?instance.provider,
  'environment': ?instance.environment,
  'productId': ?instance.productId,
  'transactionId': ?instance.transactionId,
};

Map<String, dynamic> _$AttriaxSetGdprConsentArgsToJson(
  AttriaxSetGdprConsentArgs instance,
) => <String, dynamic>{
  'analytics': instance.analytics,
  'attribution': instance.attribution,
  'adEvents': instance.adEvents,
};

Map<String, dynamic> _$AttriaxNeedsGdprConsentArgsToJson(
  AttriaxNeedsGdprConsentArgs instance,
) => <String, dynamic>{'localOnly': instance.localOnly};

Map<String, dynamic> _$AttriaxSetCcpaConsentArgsToJson(
  AttriaxSetCcpaConsentArgs instance,
) => <String, dynamic>{
  'doNotSell': ?instance.doNotSell,
  'usPrivacy': ?instance.usPrivacy,
};

Map<String, dynamic> _$AttriaxEnabledArgsToJson(AttriaxEnabledArgs instance) =>
    <String, dynamic>{'enabled': instance.enabled};

Map<String, dynamic> _$AttriaxSubmitAsaTokenArgsToJson(
  AttriaxSubmitAsaTokenArgs instance,
) => <String, dynamic>{'token': instance.token};

Map<String, dynamic> _$AttriaxSetTrackingAuthorizationStatusArgsToJson(
  AttriaxSetTrackingAuthorizationStatusArgs instance,
) => <String, dynamic>{
  'status': _trackingAuthorizationStatusToWire(instance.status),
};

Map<String, dynamic> _$AttriaxUpdateSkanConversionValueArgsToJson(
  AttriaxUpdateSkanConversionValueArgs instance,
) => <String, dynamic>{
  'fineValue': instance.fineValue,
  'coarseValue': ?_skanCoarseValueToWire(instance.coarseValue),
  'lockWindow': instance.lockWindow,
};

Map<String, dynamic> _$AttriaxCollectNativeContextArgsToJson(
  AttriaxCollectNativeContextArgs instance,
) => <String, dynamic>{'collectAdvertisingId': instance.collectAdvertisingId};

Map<String, dynamic> _$AttriaxOpenBrowserUrlArgsToJson(
  AttriaxOpenBrowserUrlArgs instance,
) => <String, dynamic>{
  'url': instance.url,
  'openMode': _resolvedUrlOpenModeToWire(instance.openMode),
};
