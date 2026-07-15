import 'package:json_annotation/json_annotation.dart';

import '../../attriax_platform_types.dart';

part 'attriax_command_args.g.dart';

/// RPC argument DTOs for the native-engine command surface.
///
/// Each class mirrors the argument `Map` one `MethodChannelAttriax` command
/// sends over the `attriax` `MethodChannel`. `toJson()` is derived by
/// `json_serializable` and reproduces the exact wire shape the native KMP / JS
/// handlers expect — key names, enum encodings, and null-omission are matched
/// 1:1 with the hand-written maps they replace.
///
/// Conventions that keep the shapes stable:
/// * `includeIfNull: false` at the class level drops `null` optionals, matching
///   the `?value` / `if (value != null)` omission the old code used.
/// * Fields that were emitted even when `null` (`setUser.userId`,
///   `setUserProperty.value`, `registerPushToken.token`) carry an explicit
///   `@JsonKey(includeIfNull: true)`.
/// * Enum fields carry a `toJson:` converter reproducing the exact wire slug.
///
/// These are outbound (Dart → native) only, so no factories are generated
/// (`createFactory: false`). Inbound result / event payloads keep their existing
/// lenient parsers.

// ---------------------------------------------------------------------------
// Lifecycle.
// ---------------------------------------------------------------------------

/// `initialize` — wraps the serialized [AttriaxConfig] under `config`.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxInitializeArgs {
  const AttriaxInitializeArgs({required this.config});

  @JsonKey(toJson: _configToJson)
  final AttriaxConfig config;

  Map<String, Object?> toJson() => _$AttriaxInitializeArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Tracking — events / page views.
// ---------------------------------------------------------------------------

/// `recordEvent` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordEventArgs {
  const AttriaxRecordEventArgs({
    required this.name,
    required this.flushImmediately,
    this.eventData,
  });

  final String name;
  final Map<String, Object?>? eventData;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordEventArgsToJson(this);
}

/// `recordPageView` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordPageViewArgs {
  const AttriaxRecordPageViewArgs({
    required this.pageName,
    required this.source,
    required this.flushImmediately,
    this.pageClass,
    this.pageTitle,
    this.previousPageName,
    this.parameters,
  });

  final String pageName;
  final String? pageClass;
  final String? pageTitle;
  final String? previousPageName;
  final Map<String, Object?>? parameters;
  final String source;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordPageViewArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Tracking — revenue / ad events.
// ---------------------------------------------------------------------------

/// `recordPurchase` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordPurchaseArgs {
  const AttriaxRecordPurchaseArgs({
    required this.revenue,
    required this.currency,
    required this.revenueInMicros,
    required this.quantity,
    required this.flushImmediately,
    this.purchaseType,
    this.productId,
    this.transactionId,
    this.originalTransactionId,
    this.validationProvider,
    this.validationEnvironment,
    this.purchaseToken,
    this.receiptData,
    this.signedPayload,
    this.receiptSignature,
    this.isRenewal,
    this.store,
    this.packageName,
    this.voided,
    this.test,
    this.validationId,
    this.metadata,
  });

  final num revenue;
  final String currency;
  final bool revenueInMicros;
  final String? purchaseType;
  final String? productId;
  final String? transactionId;
  final String? originalTransactionId;
  final String? validationProvider;
  final String? validationEnvironment;
  final String? purchaseToken;
  final String? receiptData;
  final String? signedPayload;
  final String? receiptSignature;
  final bool? isRenewal;
  final int quantity;
  final String? store;
  final String? packageName;
  final bool? voided;
  final bool? test;
  final String? validationId;
  final Map<String, Object?>? metadata;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordPurchaseArgsToJson(this);
}

/// `recordRefund` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordRefundArgs {
  const AttriaxRecordRefundArgs({
    required this.revenue,
    required this.currency,
    required this.revenueInMicros,
    required this.quantity,
    required this.flushImmediately,
    this.purchaseType,
    this.productId,
    this.transactionId,
    this.originalTransactionId,
    this.store,
    this.packageName,
    this.voided,
    this.test,
    this.reason,
    this.metadata,
  });

  final num revenue;
  final String currency;
  final bool revenueInMicros;
  final String? purchaseType;
  final String? productId;
  final String? transactionId;
  final String? originalTransactionId;
  final int quantity;
  final String? store;
  final String? packageName;
  final bool? voided;
  final bool? test;
  final String? reason;
  final Map<String, Object?>? metadata;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordRefundArgsToJson(this);
}

/// `recordAdRevenue` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordAdRevenueArgs {
  const AttriaxRecordAdRevenueArgs({
    required this.revenue,
    required this.currency,
    required this.revenueInMicros,
    required this.flushImmediately,
    this.adNetwork,
    this.adFormat,
    this.adType,
    this.adPlacement,
    this.test,
    this.metadata,
  });

  final num revenue;
  final String currency;
  final bool revenueInMicros;
  final String? adNetwork;
  final String? adFormat;
  final String? adType;
  final String? adPlacement;
  final bool? test;
  final Map<String, Object?>? metadata;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordAdRevenueArgsToJson(this);
}

/// `recordAdEvent` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordAdEventArgs {
  const AttriaxRecordAdEventArgs({
    required this.eventName,
    required this.flushImmediately,
    this.adNetwork,
    this.mediationNetwork,
    this.adUnitId,
    this.adPlacement,
    this.adFormat,
    this.adType,
    this.failureReason,
    this.loadLatencyMs,
    this.rewardType,
    this.rewardAmount,
    this.test,
    this.metadata,
  });

  final String eventName;
  final String? adNetwork;
  final String? mediationNetwork;
  final String? adUnitId;
  final String? adPlacement;
  final String? adFormat;
  final String? adType;
  final String? failureReason;
  final num? loadLatencyMs;
  final String? rewardType;
  final num? rewardAmount;
  final bool? test;
  final Map<String, Object?>? metadata;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordAdEventArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Tracking — notifications / errors.
// ---------------------------------------------------------------------------

/// `recordNotification` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordNotificationArgs {
  const AttriaxRecordNotificationArgs({
    required this.type,
    required this.notificationId,
    required this.flushImmediately,
    this.linkId,
    this.campaignId,
    this.title,
    this.source,
    this.payload,
    this.metadata,
  });

  final String type;
  final String notificationId;
  final String? linkId;
  final String? campaignId;
  final String? title;
  final String? source;
  final Map<String, Object?>? payload;
  final Map<String, Object?>? metadata;
  final bool flushImmediately;

  Map<String, Object?> toJson() => _$AttriaxRecordNotificationArgsToJson(this);
}

/// `recordError` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordErrorArgs {
  const AttriaxRecordErrorArgs({
    required this.message,
    required this.exceptionType,
    required this.fatal,
    required this.source,
    this.stackTrace,
    this.reason,
    this.metadata,
  });

  final String message;
  final String exceptionType;
  final String? stackTrace;
  final bool fatal;
  final String source;
  final String? reason;
  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => _$AttriaxRecordErrorArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Tracking — identify / user properties.
// ---------------------------------------------------------------------------

/// `setUser` arguments.
///
/// `userId` is emitted even when `null` (it is the identity clear signal); only
/// `userName` is omitted when absent.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSetUserArgs {
  const AttriaxSetUserArgs({this.userId, this.userName});

  @JsonKey(includeIfNull: true)
  final String? userId;
  final String? userName;

  Map<String, Object?> toJson() => _$AttriaxSetUserArgsToJson(this);
}

/// `setUserProperty` arguments.
///
/// `value` is emitted even when `null` (a `null` value clears the property).
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSetUserPropertyArgs {
  const AttriaxSetUserPropertyArgs({required this.name, this.value});

  final String name;

  @JsonKey(includeIfNull: true)
  final Object? value;

  Map<String, Object?> toJson() => _$AttriaxSetUserPropertyArgsToJson(this);
}

/// `setUserProperties` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSetUserPropertiesArgs {
  const AttriaxSetUserPropertiesArgs({required this.properties});

  final Map<String, Object?> properties;

  Map<String, Object?> toJson() => _$AttriaxSetUserPropertiesArgsToJson(this);
}

/// `clearUserProperties` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxClearUserPropertiesArgs {
  const AttriaxClearUserPropertiesArgs({this.propertyNames});

  final List<String>? propertyNames;

  Map<String, Object?> toJson() => _$AttriaxClearUserPropertiesArgsToJson(this);
}

/// `registerPushToken` arguments.
///
/// `token` is emitted even when `null` (a `null` token deregisters the device).
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRegisterPushTokenArgs {
  const AttriaxRegisterPushTokenArgs({
    required this.provider,
    this.token,
    this.metadata,
  });

  @JsonKey(toJson: _pushTokenProviderToWire)
  final AttriaxPushTokenProvider provider;

  @JsonKey(includeIfNull: true)
  final String? token;

  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => _$AttriaxRegisterPushTokenArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Deep links.
// ---------------------------------------------------------------------------

/// `handleIncomingLink` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxHandleIncomingLinkArgs {
  const AttriaxHandleIncomingLinkArgs({
    required this.uri,
    required this.isInitialLink,
  });

  final String uri;
  final bool isInitialLink;

  Map<String, Object?> toJson() => _$AttriaxHandleIncomingLinkArgsToJson(this);
}

/// `recordDeepLink` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxRecordDeepLinkArgs {
  const AttriaxRecordDeepLinkArgs({
    required this.uri,
    required this.source,
    this.metadata,
  });

  final String uri;
  final Map<String, Object?>? metadata;
  final String source;

  Map<String, Object?> toJson() => _$AttriaxRecordDeepLinkArgsToJson(this);
}

/// `waitForDeepLinkResolution` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxWaitForDeepLinkResolutionArgs {
  const AttriaxWaitForDeepLinkResolutionArgs({required this.rawEvent});

  @JsonKey(toJson: _rawDeepLinkEventToJson)
  final AttriaxRawDeepLinkEvent rawEvent;

  Map<String, Object?> toJson() =>
      _$AttriaxWaitForDeepLinkResolutionArgsToJson(this);
}

/// `createDynamicLink` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxCreateDynamicLinkArgs {
  AttriaxCreateDynamicLinkArgs({
    this.name,
    this.destinationUrl,
    this.group,
    this.prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    this.data,
  }) : socialPreview = socialPreview == null
           ? null
           : AttriaxDynamicLinkSocialPreviewArgs.from(socialPreview),
       utms = utms == null ? null : AttriaxDynamicLinkUtmsArgs.from(utms),
       redirects = redirects == null
           ? null
           : AttriaxDynamicLinkRedirectsArgs.from(redirects);

  final String? name;
  final String? destinationUrl;
  final String? group;
  final String? prefix;
  @JsonKey(toJson: _socialPreviewArgsToJson)
  final AttriaxDynamicLinkSocialPreviewArgs? socialPreview;
  @JsonKey(toJson: _utmsArgsToJson)
  final AttriaxDynamicLinkUtmsArgs? utms;
  @JsonKey(toJson: _redirectsArgsToJson)
  final AttriaxDynamicLinkRedirectsArgs? redirects;
  final Map<String, Object?>? data;

  Map<String, Object?> toJson() => _$AttriaxCreateDynamicLinkArgsToJson(this);
}

/// Nested `socialPreview` object of [AttriaxCreateDynamicLinkArgs].
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxDynamicLinkSocialPreviewArgs {
  const AttriaxDynamicLinkSocialPreviewArgs({this.title, this.description});

  factory AttriaxDynamicLinkSocialPreviewArgs.from(
    AttriaxDynamicLinkSocialPreview source,
  ) => AttriaxDynamicLinkSocialPreviewArgs(
    title: source.title,
    description: source.description,
  );

  final String? title;
  final String? description;

  Map<String, Object?> toJson() =>
      _$AttriaxDynamicLinkSocialPreviewArgsToJson(this);
}

/// Nested `utms` object of [AttriaxCreateDynamicLinkArgs].
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxDynamicLinkUtmsArgs {
  const AttriaxDynamicLinkUtmsArgs({
    this.source,
    this.medium,
    this.campaign,
    this.term,
    this.content,
  });

  factory AttriaxDynamicLinkUtmsArgs.from(AttriaxDynamicLinkUtms source) =>
      AttriaxDynamicLinkUtmsArgs(
        source: source.source,
        medium: source.medium,
        campaign: source.campaign,
        term: source.term,
        content: source.content,
      );

  final String? source;
  final String? medium;
  final String? campaign;
  final String? term;
  final String? content;

  Map<String, Object?> toJson() => _$AttriaxDynamicLinkUtmsArgsToJson(this);
}

/// Nested `redirects` object of [AttriaxCreateDynamicLinkArgs].
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxDynamicLinkRedirectsArgs {
  const AttriaxDynamicLinkRedirectsArgs({this.ios, this.android});

  factory AttriaxDynamicLinkRedirectsArgs.from(
    AttriaxDynamicLinkRedirects source,
  ) =>
      AttriaxDynamicLinkRedirectsArgs(ios: source.ios, android: source.android);

  final bool? ios;
  final bool? android;

  Map<String, Object?> toJson() =>
      _$AttriaxDynamicLinkRedirectsArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Revenue receipt validation.
// ---------------------------------------------------------------------------

/// `validateReceipt` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxValidateReceiptArgs {
  const AttriaxValidateReceiptArgs({
    required this.receipt,
    required this.test,
    this.provider,
    this.environment,
    this.productId,
    this.transactionId,
  });

  final String receipt;
  final bool test;
  final String? provider;
  final String? environment;
  final String? productId;
  final String? transactionId;

  Map<String, Object?> toJson() => _$AttriaxValidateReceiptArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Consent — GDPR / CCPA.
// ---------------------------------------------------------------------------

/// `setGdprConsent` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSetGdprConsentArgs {
  const AttriaxSetGdprConsentArgs({
    required this.analytics,
    required this.attribution,
    required this.adEvents,
  });

  final bool analytics;
  final bool attribution;
  final bool adEvents;

  Map<String, Object?> toJson() => _$AttriaxSetGdprConsentArgsToJson(this);
}

/// `needsGdprConsent` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxNeedsGdprConsentArgs {
  const AttriaxNeedsGdprConsentArgs({required this.localOnly});

  final bool localOnly;

  Map<String, Object?> toJson() => _$AttriaxNeedsGdprConsentArgsToJson(this);
}

/// `setCcpaConsent` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSetCcpaConsentArgs {
  const AttriaxSetCcpaConsentArgs({this.doNotSell, this.usPrivacy});

  final bool? doNotSell;
  final String? usPrivacy;

  Map<String, Object?> toJson() => _$AttriaxSetCcpaConsentArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Toggles.
// ---------------------------------------------------------------------------

/// Shared `{ 'enabled': bool }` argument shape for the boolean toggle commands
/// (`setSdkEnabled`, `setEventTrackingEnabled`, `setAnonymousTracking`,
/// `setAutomaticCrashReportingEnabled`).
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxEnabledArgs {
  const AttriaxEnabledArgs({required this.enabled});

  final bool enabled;

  Map<String, Object?> toJson() => _$AttriaxEnabledArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Apple seams.
// ---------------------------------------------------------------------------

/// `submitAsaToken` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSubmitAsaTokenArgs {
  const AttriaxSubmitAsaTokenArgs({required this.token});

  final String token;

  Map<String, Object?> toJson() => _$AttriaxSubmitAsaTokenArgsToJson(this);
}

/// `setTrackingAuthorizationStatus` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxSetTrackingAuthorizationStatusArgs {
  const AttriaxSetTrackingAuthorizationStatusArgs({required this.status});

  @JsonKey(toJson: _trackingAuthorizationStatusToWire)
  final AttriaxTrackingAuthorizationStatus status;

  Map<String, Object?> toJson() =>
      _$AttriaxSetTrackingAuthorizationStatusArgsToJson(this);
}

/// `updateSkanConversionValue` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxUpdateSkanConversionValueArgs {
  const AttriaxUpdateSkanConversionValueArgs({
    required this.fineValue,
    required this.lockWindow,
    this.coarseValue,
  });

  final int fineValue;

  @JsonKey(toJson: _skanCoarseValueToWire)
  final AttriaxSkanCoarseValue? coarseValue;

  final bool lockWindow;

  Map<String, Object?> toJson() =>
      _$AttriaxUpdateSkanConversionValueArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Retained legacy signal surface.
// ---------------------------------------------------------------------------

/// `collectNativeContext` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxCollectNativeContextArgs {
  const AttriaxCollectNativeContextArgs({required this.collectAdvertisingId});

  final bool collectAdvertisingId;

  Map<String, Object?> toJson() =>
      _$AttriaxCollectNativeContextArgsToJson(this);
}

/// `openBrowserUrl` arguments.
@JsonSerializable(includeIfNull: false, createFactory: false)
class AttriaxOpenBrowserUrlArgs {
  const AttriaxOpenBrowserUrlArgs({required this.url, required this.openMode});

  @JsonKey(name: 'url')
  final String url;

  @JsonKey(toJson: _resolvedUrlOpenModeToWire)
  final AttriaxResolvedUrlOpenMode openMode;

  Map<String, Object?> toJson() => _$AttriaxOpenBrowserUrlArgsToJson(this);
}

// ---------------------------------------------------------------------------
// Enum / nested wire converters (byte-for-byte with the retired hand code).
// ---------------------------------------------------------------------------

Map<String, Object?> _configToJson(AttriaxConfig config) => config.toJson();

// Nested custom types must be lowered to their `Map` here: the MethodChannel's
// StandardMessageCodec (unlike `jsonEncode`) does NOT call `toJson()` on nested
// objects, so json_serializable's default "emit the object" would break the
// wire. These converters reproduce the maps the retired hand code sent.
Map<String, Object?> _rawDeepLinkEventToJson(AttriaxRawDeepLinkEvent event) =>
    event.toJson();

Map<String, Object?>? _socialPreviewArgsToJson(
  AttriaxDynamicLinkSocialPreviewArgs? value,
) => value?.toJson();

Map<String, Object?>? _utmsArgsToJson(AttriaxDynamicLinkUtmsArgs? value) =>
    value?.toJson();

Map<String, Object?>? _redirectsArgsToJson(
  AttriaxDynamicLinkRedirectsArgs? value,
) => value?.toJson();

String _pushTokenProviderToWire(AttriaxPushTokenProvider provider) =>
    provider.wireValue;

String? _skanCoarseValueToWire(AttriaxSkanCoarseValue? value) => value?.name;

String _trackingAuthorizationStatusToWire(
  AttriaxTrackingAuthorizationStatus status,
) => switch (status) {
  AttriaxTrackingAuthorizationStatus.notSupported => 'not_supported',
  AttriaxTrackingAuthorizationStatus.disabled => 'disabled',
  AttriaxTrackingAuthorizationStatus.notDetermined => 'not_determined',
  AttriaxTrackingAuthorizationStatus.restricted => 'restricted',
  AttriaxTrackingAuthorizationStatus.denied => 'denied',
  AttriaxTrackingAuthorizationStatus.authorized => 'authorized',
  AttriaxTrackingAuthorizationStatus.timedOut => 'timed_out',
  AttriaxTrackingAuthorizationStatus.unknown => 'unknown',
};

String _resolvedUrlOpenModeToWire(AttriaxResolvedUrlOpenMode openMode) =>
    switch (openMode) {
      AttriaxResolvedUrlOpenMode.external => 'external',
      AttriaxResolvedUrlOpenMode.inApp ||
      AttriaxResolvedUrlOpenMode.unknown => 'in_app',
    };
