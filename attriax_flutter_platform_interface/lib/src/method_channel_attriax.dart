import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import '../attriax_platform_types.dart';

import 'attriax_platform_interface.dart';
import 'marshalling/attriax_command_args.dart';

/// EventChannel name for synchronization-state transitions.
const String attriaxSynchronizationEventChannelName =
    'attriax/events/synchronization';

/// EventChannel name for resolved deep-link events.
const String attriaxDeepLinkEventChannelName = 'attriax/events/deep_links';

/// EventChannel name for raw (pre-resolution) deep-link inputs.
const String attriaxRawDeepLinkEventChannelName =
    'attriax/events/raw_deep_links';

/// EventChannel name for initial-link probe resolutions.
const String attriaxInitialDeepLinkEventChannelName =
    'attriax/events/initial_deep_link';

/// An implementation of [AttriaxPlatform] that uses method + event channels.
class MethodChannelAttriax extends AttriaxPlatform {
  MethodChannelAttriax({
    MethodChannel? channel,
    EventChannel? synchronizationEventChannel,
    EventChannel? deepLinkEventChannel,
    EventChannel? rawDeepLinkEventChannel,
    EventChannel? initialDeepLinkEventChannel,
    String logName = 'attriax.platform_interface',
  }) : _channel = channel ?? const MethodChannel('attriax'),
       _synchronizationEventChannel =
           synchronizationEventChannel ??
           const EventChannel(attriaxSynchronizationEventChannelName),
       _deepLinkEventChannel =
           deepLinkEventChannel ??
           const EventChannel(attriaxDeepLinkEventChannelName),
       _rawDeepLinkEventChannel =
           rawDeepLinkEventChannel ??
           const EventChannel(attriaxRawDeepLinkEventChannelName),
       _initialDeepLinkEventChannel =
           initialDeepLinkEventChannel ??
           const EventChannel(attriaxInitialDeepLinkEventChannelName),
       _logName = logName;

  final MethodChannel _channel;
  final EventChannel _synchronizationEventChannel;
  final EventChannel _deepLinkEventChannel;
  final EventChannel _rawDeepLinkEventChannel;
  final EventChannel _initialDeepLinkEventChannel;
  final String _logName;

  // ---------------------------------------------------------------------------
  // Lifecycle.
  // ---------------------------------------------------------------------------

  @override
  Future<void> initialize(AttriaxConfig config) =>
      _invokeVoid('initialize', AttriaxInitializeArgs(config: config).toJson());

  @override
  Future<void> flush() => _invokeVoid('flush');

  @override
  Future<void> reset() => _invokeVoid('reset');

  @override
  Future<void> dispose() => _invokeVoid('dispose');

  // ---------------------------------------------------------------------------
  // Tracking — events / page views.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordEvent(
    String name, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) => _invokeVoid(
    'recordEvent',
    AttriaxRecordEventArgs(
      name: name,
      eventData: eventData,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  @override
  Future<void> recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) => _invokeVoid(
    'recordPageView',
    AttriaxRecordPageViewArgs(
      pageName: pageName,
      pageClass: pageClass,
      pageTitle: pageTitle,
      previousPageName: previousPageName,
      parameters: parameters,
      source: source,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  // ---------------------------------------------------------------------------
  // Tracking — revenue / ad events.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordPurchase({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    String? validationProvider,
    String? validationEnvironment,
    String? purchaseToken,
    String? receiptData,
    String? signedPayload,
    String? receiptSignature,
    bool? isRenewal,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? validationId,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) => _invokeVoid(
    'recordPurchase',
    AttriaxRecordPurchaseArgs(
      revenue: revenue,
      currency: currency,
      revenueInMicros: revenueInMicros,
      purchaseType: purchaseType,
      productId: productId,
      transactionId: transactionId,
      originalTransactionId: originalTransactionId,
      validationProvider: validationProvider,
      validationEnvironment: validationEnvironment,
      purchaseToken: purchaseToken,
      receiptData: receiptData,
      signedPayload: signedPayload,
      receiptSignature: receiptSignature,
      isRenewal: isRenewal,
      quantity: quantity,
      store: store,
      packageName: packageName,
      voided: voided,
      test: test,
      validationId: validationId,
      metadata: metadata,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  @override
  Future<void> recordRefund({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? purchaseType,
    String? productId,
    String? transactionId,
    String? originalTransactionId,
    int quantity = 1,
    String? store,
    String? packageName,
    bool? voided,
    bool? test,
    String? reason,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) => _invokeVoid(
    'recordRefund',
    AttriaxRecordRefundArgs(
      revenue: revenue,
      currency: currency,
      revenueInMicros: revenueInMicros,
      purchaseType: purchaseType,
      productId: productId,
      transactionId: transactionId,
      originalTransactionId: originalTransactionId,
      quantity: quantity,
      store: store,
      packageName: packageName,
      voided: voided,
      test: test,
      reason: reason,
      metadata: metadata,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  @override
  Future<void> recordAdRevenue({
    required num revenue,
    String currency = 'USD',
    bool revenueInMicros = false,
    String? adNetwork,
    String? adFormat,
    String? adType,
    String? adPlacement,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) => _invokeVoid(
    'recordAdRevenue',
    AttriaxRecordAdRevenueArgs(
      revenue: revenue,
      currency: currency,
      revenueInMicros: revenueInMicros,
      adNetwork: adNetwork,
      adFormat: adFormat,
      adType: adType,
      adPlacement: adPlacement,
      test: test,
      metadata: metadata,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  @override
  Future<void> recordAdEvent({
    required String eventName,
    String? adNetwork,
    String? mediationNetwork,
    String? adUnitId,
    String? adPlacement,
    String? adFormat,
    String? adType,
    String? failureReason,
    num? loadLatencyMs,
    String? rewardType,
    num? rewardAmount,
    bool? test,
    Map<String, Object?>? metadata,
    bool flushImmediately = true,
  }) => _invokeVoid(
    'recordAdEvent',
    AttriaxRecordAdEventArgs(
      eventName: eventName,
      adNetwork: adNetwork,
      mediationNetwork: mediationNetwork,
      adUnitId: adUnitId,
      adPlacement: adPlacement,
      adFormat: adFormat,
      adType: adType,
      failureReason: failureReason,
      loadLatencyMs: loadLatencyMs,
      rewardType: rewardType,
      rewardAmount: rewardAmount,
      test: test,
      metadata: metadata,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  // ---------------------------------------------------------------------------
  // Tracking — notifications / errors.
  // ---------------------------------------------------------------------------

  @override
  Future<void> recordNotification({
    required String type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    String? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) => _invokeVoid(
    'recordNotification',
    AttriaxRecordNotificationArgs(
      type: type,
      notificationId: notificationId,
      linkId: linkId,
      campaignId: campaignId,
      title: title,
      source: source,
      payload: payload,
      metadata: metadata,
      flushImmediately: flushImmediately,
    ).toJson(),
  );

  @override
  Future<void> recordError({
    required String message,
    required String exceptionType,
    String? stackTrace,
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) => _invokeVoid(
    'recordError',
    AttriaxRecordErrorArgs(
      message: message,
      exceptionType: exceptionType,
      stackTrace: stackTrace,
      fatal: fatal,
      source: source,
      reason: reason,
      metadata: metadata,
    ).toJson(),
  );

  // ---------------------------------------------------------------------------
  // Tracking — identify / user properties.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setUser({String? userId, String? userName}) => _invokeVoid(
    'setUser',
    AttriaxSetUserArgs(userId: userId, userName: userName).toJson(),
  );

  @override
  Future<void> setUserProperty(String name, Object? value) => _invokeVoid(
    'setUserProperty',
    AttriaxSetUserPropertyArgs(name: name, value: value).toJson(),
  );

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) =>
      _invokeVoid(
        'setUserProperties',
        AttriaxSetUserPropertiesArgs(properties: properties).toJson(),
      );

  @override
  Future<void> clearUserProperties({List<String>? propertyNames}) =>
      _invokeVoid(
        'clearUserProperties',
        AttriaxClearUserPropertiesArgs(propertyNames: propertyNames).toJson(),
      );

  @override
  Future<void> registerPushToken({
    required AttriaxPushTokenProvider provider,
    String? token,
    Map<String, Object?>? metadata,
  }) => _invokeVoid(
    'registerPushToken',
    AttriaxRegisterPushTokenArgs(
      provider: provider,
      token: token,
      metadata: metadata,
    ).toJson(),
  );

  // ---------------------------------------------------------------------------
  // Deep links.
  // ---------------------------------------------------------------------------

  @override
  Future<void> handleIncomingLink(String uri, {bool isInitialLink = false}) =>
      _invokeVoid(
        'handleIncomingLink',
        AttriaxHandleIncomingLinkArgs(
          uri: uri,
          isInitialLink: isInitialLink,
        ).toJson(),
      );

  @override
  Future<void> completeInitialDeepLink() =>
      _invokeVoid('completeInitialDeepLink');

  @override
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'recordDeepLink',
        AttriaxRecordDeepLinkArgs(
          uri: uri.toString(),
          metadata: metadata,
          source: source,
        ).toJson(),
      );
      return _deepLinkEventFromMap(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('recordDeepLink', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('recordDeepLink', error, stackTrace);
      return null;
    }
  }

  @override
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'waitForInitialDeepLink',
      );
      return _deepLinkEventFromMap(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('waitForInitialDeepLink', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('waitForInitialDeepLink', error, stackTrace);
      return null;
    }
  }

  @override
  Future<AttriaxDeepLinkEvent?> waitForDeepLinkResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'waitForDeepLinkResolution',
        AttriaxWaitForDeepLinkResolutionArgs(rawEvent: rawEvent).toJson(),
      );
      return _deepLinkEventFromMap(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('waitForDeepLinkResolution', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('waitForDeepLinkResolution', error, stackTrace);
      return null;
    }
  }

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'createDynamicLink',
      AttriaxCreateDynamicLinkArgs(
        name: name,
        destinationUrl: destinationUrl,
        group: group,
        prefix: prefix,
        socialPreview: socialPreview,
        utms: utms,
        redirects: redirects,
        data: data,
      ).toJson(),
    );
    if (result == null) {
      throw StateError('Attriax createDynamicLink response was empty.');
    }
    return AttriaxCreateDynamicLinkResult.fromJson(result);
  }

  // ---------------------------------------------------------------------------
  // Revenue receipt validation.
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxRevenueReceiptValidationResult> validateReceipt({
    required String receipt,
    bool test = false,
    String? provider,
    String? environment,
    String? productId,
    String? transactionId,
  }) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'validateReceipt',
      AttriaxValidateReceiptArgs(
        receipt: receipt,
        test: test,
        provider: provider,
        environment: environment,
        productId: productId,
        transactionId: transactionId,
      ).toJson(),
    );
    if (result == null) {
      throw StateError('Attriax validateReceipt response was empty.');
    }
    return AttriaxRevenueReceiptValidationResult.fromJson(result);
  }

  // ---------------------------------------------------------------------------
  // Consent — GDPR.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setGdprConsent({
    required bool analytics,
    required bool attribution,
    required bool adEvents,
  }) => _invokeVoid(
    'setGdprConsent',
    AttriaxSetGdprConsentArgs(
      analytics: analytics,
      attribution: attribution,
      adEvents: adEvents,
    ).toJson(),
  );

  @override
  Future<void> setGdprConsentNotRequired() =>
      _invokeVoid('setGdprConsentNotRequired');

  @override
  Future<void> resetGdprConsent() => _invokeVoid('resetGdprConsent');

  @override
  Future<void> requestGdprDataErasure() =>
      _invokeVoid('requestGdprDataErasure');

  @override
  Future<bool> needsGdprConsent({bool localOnly = false}) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'needsGdprConsent',
        AttriaxNeedsGdprConsentArgs(localOnly: localOnly).toJson(),
      );
      return result == true;
    } on MissingPluginException catch (error, stackTrace) {
      _logException('needsGdprConsent', error, stackTrace);
      return false;
    } on PlatformException catch (error, stackTrace) {
      _logException('needsGdprConsent', error, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> getIsWaitingForGdprConsent() =>
      _invokeBool('getIsWaitingForGdprConsent');

  // ---------------------------------------------------------------------------
  // Toggles.
  // ---------------------------------------------------------------------------

  @override
  Future<void> setAnonymousTracking({required bool enabled}) => _invokeVoid(
    'setAnonymousTracking',
    AttriaxEnabledArgs(enabled: enabled).toJson(),
  );

  @override
  Future<void> setCcpaConsent({bool? doNotSell, String? usPrivacy}) =>
      _invokeVoid(
        'setCcpaConsent',
        AttriaxSetCcpaConsentArgs(
          doNotSell: doNotSell,
          usPrivacy: usPrivacy,
        ).toJson(),
      );

  @override
  Future<void> setSdkEnabled({required bool enabled}) => _invokeVoid(
    'setSdkEnabled',
    AttriaxEnabledArgs(enabled: enabled).toJson(),
  );

  @override
  Future<void> setEventTrackingEnabled({required bool enabled}) => _invokeVoid(
    'setEventTrackingEnabled',
    AttriaxEnabledArgs(enabled: enabled).toJson(),
  );

  // ---------------------------------------------------------------------------
  // Apple seams.
  // ---------------------------------------------------------------------------

  @override
  Future<void> submitAsaToken(String token) => _invokeVoid(
    'submitAsaToken',
    AttriaxSubmitAsaTokenArgs(token: token).toJson(),
  );

  @override
  Future<void> setTrackingAuthorizationStatus(
    AttriaxTrackingAuthorizationStatus status,
  ) => _invokeVoid(
    'setTrackingAuthorizationStatus',
    AttriaxSetTrackingAuthorizationStatusArgs(status: status).toJson(),
  );

  // ---------------------------------------------------------------------------
  // Engine reads.
  // ---------------------------------------------------------------------------

  @override
  Future<String?> getDeviceId() => _invokeNullableString('getDeviceId');

  @override
  Future<bool> getIsFirstLaunch() => _invokeBool('getIsFirstLaunch');

  @override
  Future<bool> getIsInitialized() => _invokeBool('getIsInitialized');

  @override
  Future<AttriaxSdkSnapshot?> getSdkSnapshot() async {
    final result = await _invokeMap('getSdkSnapshot');
    return result == null ? null : AttriaxSdkSnapshot.fromPayload(result);
  }

  @override
  Future<bool> getSdkEnabled() => _invokeBool('getSdkEnabled');

  @override
  Future<bool> getEventTrackingEnabled() =>
      _invokeBool('getEventTrackingEnabled');

  @override
  Future<bool> getAnonymousTracking() => _invokeBool('getAnonymousTracking');

  @override
  Future<AttriaxSynchronizationState> getSynchronizationState() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'getSynchronizationState',
      );
      return _synchronizationStateFromWire(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('getSynchronizationState', error, stackTrace);
      return AttriaxSynchronizationState.initializing;
    } on PlatformException catch (error, stackTrace) {
      _logException('getSynchronizationState', error, stackTrace);
      return AttriaxSynchronizationState.initializing;
    }
  }

  @override
  Future<bool> getIsSynchronized() => _invokeBool('getIsSynchronized');

  @override
  Future<AttriaxInstallReferrerDetails?> getOriginalInstallReferrer({
    Duration? timeout,
  }) => _installReferrerDetails('getOriginalInstallReferrer', timeout);

  @override
  Future<AttriaxInstallReferrerDetails?> getReinstallReferrer({
    Duration? timeout,
  }) => _installReferrerDetails('getReinstallReferrer', timeout);

  @override
  Future<String?> getRawInstallReferrer({Duration? timeout}) =>
      _invokeNullableString('getRawInstallReferrer', _timeoutArgs(timeout));

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getSessionReferrer({
    Duration? timeout,
  }) => _deepLinkReferrerDetails('getSessionReferrer', timeout);

  @override
  Future<AttriaxDeepLinkReferrerDetails?> getLatestDeepLinkReferrer({
    Duration? timeout,
  }) => _deepLinkReferrerDetails('getLatestDeepLinkReferrer', timeout);

  @override
  Future<AttriaxSkanState?> getSkanState() async {
    final result = await _invokeMap('getSkanState');
    return result == null ? null : AttriaxSkanState.fromPayload(result);
  }

  @override
  Future<AttriaxDeepLinkEvent?> getLatestDeepLink() async =>
      _deepLinkEventFromMap(await _invokeMap('getLatestDeepLink'));

  @override
  Future<AttriaxDeepLinkEvent?> getInitialDeepLink() async =>
      _deepLinkEventFromMap(await _invokeMap('getInitialDeepLink'));

  @override
  Future<AttriaxRawDeepLinkEvent?> getRawInitialDeepLink() async {
    final result = await _invokeMap('getRawInitialDeepLink');
    if (result == null) {
      return null;
    }
    try {
      return AttriaxRawDeepLinkEvent.fromJson(result);
    } on FormatException catch (error, stackTrace) {
      _logException('getRawInitialDeepLink', error, stackTrace);
      return null;
    }
  }

  @override
  Future<bool> getIsInitialDeepLinkResolved() =>
      _invokeBool('getIsInitialDeepLinkResolved');

  // ---------------------------------------------------------------------------
  // Event streams.
  // ---------------------------------------------------------------------------

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _synchronizationEventChannel
          .receiveBroadcastStream()
          .map(_synchronizationStateFromWire);

  @override
  Stream<AttriaxDeepLinkEvent> get deepLinkEvents => _deepLinkEventChannel
      .receiveBroadcastStream()
      .map(_deepLinkEventFromPayload)
      .where((event) => event != null)
      .cast<AttriaxDeepLinkEvent>();

  @override
  Stream<AttriaxRawDeepLinkEvent> get rawDeepLinkEvents =>
      _rawDeepLinkEventChannel
          .receiveBroadcastStream()
          .map(_rawDeepLinkEventFromPayload)
          .where((event) => event != null)
          .cast<AttriaxRawDeepLinkEvent>();

  @override
  Stream<AttriaxInitialDeepLinkResolution> get initialDeepLinkResolutions =>
      _initialDeepLinkEventChannel
          .receiveBroadcastStream()
          .map(_initialDeepLinkResolutionFromPayload)
          .where((event) => event != null)
          .cast<AttriaxInitialDeepLinkResolution>();

  // ---------------------------------------------------------------------------
  // Retained legacy signal surface.
  // ---------------------------------------------------------------------------

  @override
  Future<AttriaxNativeContext> collectNativeContext({
    bool collectAdvertisingId = true,
  }) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'collectNativeContext',
        AttriaxCollectNativeContextArgs(
          collectAdvertisingId: collectAdvertisingId,
        ).toJson(),
      );
      return AttriaxNativeContext.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('collectNativeContext', error, stackTrace);
      return const AttriaxNativeContext();
    } on PlatformException catch (error, stackTrace) {
      _logException('collectNativeContext', error, stackTrace);
      return const AttriaxNativeContext();
    }
  }

  @override
  Future<AttriaxInstallReferrerContext> collectInstallReferrer() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'collectInstallReferrer',
      );
      return AttriaxInstallReferrerContext.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('collectInstallReferrer', error, stackTrace);
      return missingPluginInstallReferrerContext(error);
    } on PlatformException catch (error, stackTrace) {
      _logException('collectInstallReferrer', error, stackTrace);
      return platformExceptionInstallReferrerContext(error);
    }
  }

  @override
  Future<String?> readAttributionClipboard() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'readAttributionClipboard',
      );
      return result is String && result.trim().isNotEmpty
          ? result.trim()
          : null;
    } on MissingPluginException catch (error, stackTrace) {
      _logException('readAttributionClipboard', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('readAttributionClipboard', error, stackTrace);
      return null;
    }
  }

  @override
  Future<String?> collectWebViewUserAgent() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'collectWebViewUserAgent',
      );
      return result is String && result.trim().isNotEmpty
          ? result.trim()
          : null;
    } on MissingPluginException catch (error, stackTrace) {
      _logException('collectWebViewUserAgent', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('collectWebViewUserAgent', error, stackTrace);
      return null;
    }
  }

  @override
  Future<AttriaxPendingCrashReport?> consumePendingCrashReport() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'consumePendingCrashReport',
      );
      if (result == null) {
        return null;
      }

      return AttriaxPendingCrashReport.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('consumePendingCrashReport', error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException('consumePendingCrashReport', error, stackTrace);
      return null;
    } on FormatException catch (error, stackTrace) {
      _logException('consumePendingCrashReport', error, stackTrace);
      return null;
    }
  }

  @override
  Future<void> setAutomaticCrashReportingEnabled({
    required bool enabled,
  }) async {
    try {
      await _channel.invokeMethod<Object?>(
        'setAutomaticCrashReportingEnabled',
        AttriaxEnabledArgs(enabled: enabled).toJson(),
      );
    } on MissingPluginException catch (error, stackTrace) {
      _logException('setAutomaticCrashReportingEnabled', error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _logException('setAutomaticCrashReportingEnabled', error, stackTrace);
    }
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus>
  getTrackingAuthorizationStatus() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'getTrackingAuthorizationStatus',
      );
      return _trackingAuthorizationStatusFromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('getTrackingAuthorizationStatus', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.notSupported;
    } on PlatformException catch (error, stackTrace) {
      _logException('getTrackingAuthorizationStatus', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.unknown;
    }
  }

  @override
  Future<AttriaxTrackingAuthorizationStatus> requestTrackingAuthorization({
    Duration? timeout,
  }) async {
    try {
      final invocation = _channel.invokeMethod<Object?>(
        'requestTrackingAuthorization',
      );
      final result = timeout == null
          ? await invocation
          : await invocation.timeout(timeout);
      return _trackingAuthorizationStatusFromPayload(result);
    } on TimeoutException {
      return AttriaxTrackingAuthorizationStatus.timedOut;
    } on MissingPluginException catch (error, stackTrace) {
      _logException('requestTrackingAuthorization', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.notSupported;
    } on PlatformException catch (error, stackTrace) {
      _logException('requestTrackingAuthorization', error, stackTrace);
      return AttriaxTrackingAuthorizationStatus.unknown;
    }
  }

  @override
  Future<bool> openBrowserUrl({
    required Uri uri,
    required AttriaxResolvedUrlOpenMode openMode,
  }) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'openBrowserUrl',
        AttriaxOpenBrowserUrlArgs(
          url: uri.toString(),
          openMode: openMode,
        ).toJson(),
      );
      return result == true;
    } on MissingPluginException catch (error, stackTrace) {
      _logException('openBrowserUrl', error, stackTrace);
      return false;
    } on PlatformException catch (error, stackTrace) {
      _logException('openBrowserUrl', error, stackTrace);
      return false;
    }
  }

  @override
  Future<AttriaxSkanUpdateResult> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'updateSkanConversionValue',
        AttriaxUpdateSkanConversionValueArgs(
          fineValue: fineValue,
          coarseValue: coarseValue,
          lockWindow: lockWindow,
        ).toJson(),
      );
      return AttriaxSkanUpdateResult.fromPayload(result);
    } on MissingPluginException catch (error, stackTrace) {
      _logException('updateSkanConversionValue', error, stackTrace);
      return const AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.notSupported,
        message:
            'SKAdNetwork conversion updates are not supported on this platform.',
      );
    } on PlatformException catch (error, stackTrace) {
      _logException('updateSkanConversionValue', error, stackTrace);
      return AttriaxSkanUpdateResult(
        status: AttriaxSkanUpdateStatus.error,
        message: error.message,
      );
    }
  }

  AttriaxInstallReferrerContext missingPluginInstallReferrerContext(
    MissingPluginException error,
  ) => const AttriaxInstallReferrerContext();

  AttriaxInstallReferrerContext platformExceptionInstallReferrerContext(
    PlatformException error,
  ) => const AttriaxInstallReferrerContext();

  // ---------------------------------------------------------------------------
  // Invocation helpers.
  // ---------------------------------------------------------------------------

  /// Fire-and-forget invocation: best-effort, swallow + log channel errors.
  Future<void> _invokeVoid(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      await _channel.invokeMethod<Object?>(method, arguments);
    } on MissingPluginException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
    }
  }

  /// Invoke a method returning a `bool`; benign `false` on a missing plugin.
  Future<bool> _invokeBool(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      final result = await _channel.invokeMethod<Object?>(method, arguments);
      return result == true;
    } on MissingPluginException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return false;
    } on PlatformException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return false;
    }
  }

  /// Invoke a method returning a nullable `String`; benign `null` on failure.
  Future<String?> _invokeNullableString(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      final result = await _channel.invokeMethod<Object?>(method, arguments);
      return result is String && result.trim().isNotEmpty
          ? result.trim()
          : null;
    } on MissingPluginException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return null;
    }
  }

  /// Invoke a method returning a nullable map; benign `null` on failure.
  Future<Map<String, Object?>?> _invokeMap(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    try {
      return await _channel.invokeMapMethod<String, Object?>(method, arguments);
    } on MissingPluginException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return null;
    }
  }

  Future<AttriaxInstallReferrerDetails?> _installReferrerDetails(
    String method,
    Duration? timeout,
  ) async {
    final result = await _invokeMap(method, _timeoutArgs(timeout));
    if (result == null) {
      return null;
    }
    try {
      return AttriaxInstallReferrerDetails.fromJson(result);
    } on FormatException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return null;
    }
  }

  Future<AttriaxDeepLinkReferrerDetails?> _deepLinkReferrerDetails(
    String method,
    Duration? timeout,
  ) async {
    final result = await _invokeMap(method, _timeoutArgs(timeout));
    if (result == null) {
      return null;
    }
    try {
      return AttriaxDeepLinkReferrerDetails.fromJson(result);
    } on FormatException catch (error, stackTrace) {
      _logException(method, error, stackTrace);
      return null;
    }
  }

  Map<String, Object?>? _timeoutArgs(Duration? timeout) => timeout == null
      ? null
      : <String, Object?>{'timeoutMs': timeout.inMilliseconds};

  AttriaxDeepLinkEvent? _deepLinkEventFromMap(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    try {
      return AttriaxDeepLinkEvent.fromJson(json);
    } on FormatException catch (error, stackTrace) {
      _logException('deepLinkEvent', error, stackTrace);
      return null;
    }
  }

  AttriaxDeepLinkEvent? _deepLinkEventFromPayload(Object? payload) =>
      _deepLinkEventFromMap(_asStringKeyedMap(payload));

  AttriaxRawDeepLinkEvent? _rawDeepLinkEventFromPayload(Object? payload) {
    final json = _asStringKeyedMap(payload);
    if (json == null) {
      return null;
    }
    try {
      return AttriaxRawDeepLinkEvent.fromJson(json);
    } on FormatException catch (error, stackTrace) {
      _logException('rawDeepLinkEvent', error, stackTrace);
      return null;
    }
  }

  AttriaxInitialDeepLinkResolution? _initialDeepLinkResolutionFromPayload(
    Object? payload,
  ) {
    final json = _asStringKeyedMap(payload);
    if (json == null) {
      return null;
    }
    try {
      return AttriaxInitialDeepLinkResolution.fromJson(json);
    } on FormatException catch (error, stackTrace) {
      _logException('initialDeepLinkResolution', error, stackTrace);
      return null;
    }
  }

  Map<String, Object?>? _asStringKeyedMap(Object? value) {
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(key.toString(), nestedValue),
      );
    }
    return null;
  }

  AttriaxSynchronizationState _synchronizationStateFromWire(Object? wire) =>
      switch (wire) {
        'initializing' || 'INITIALIZING' =>
          AttriaxSynchronizationState.initializing,
        'synchronizing' || 'SYNCHRONIZING' =>
          AttriaxSynchronizationState.synchronizing,
        'deferred' || 'DEFERRED' => AttriaxSynchronizationState.deferred,
        'synchronized' || 'SYNCHRONIZED' =>
          AttriaxSynchronizationState.synchronized,
        'offline' || 'OFFLINE' => AttriaxSynchronizationState.offline,
        'failed' || 'FAILED' => AttriaxSynchronizationState.failed,
        'disabled' || 'DISABLED' => AttriaxSynchronizationState.disabled,
        _ => AttriaxSynchronizationState.initializing,
      };

  void _logException(String method, Object error, StackTrace stackTrace) {
    developer.log(
      '$runtimeType.$method failed: ${error.runtimeType}',
      name: _logName,
      error: error,
      stackTrace: stackTrace,
    );
  }

  AttriaxTrackingAuthorizationStatus _trackingAuthorizationStatusFromPayload(
    Object? payload,
  ) => switch (payload) {
    'not_supported' => AttriaxTrackingAuthorizationStatus.notSupported,
    'not_determined' => AttriaxTrackingAuthorizationStatus.notDetermined,
    'restricted' => AttriaxTrackingAuthorizationStatus.restricted,
    'denied' => AttriaxTrackingAuthorizationStatus.denied,
    'authorized' => AttriaxTrackingAuthorizationStatus.authorized,
    'timed_out' => AttriaxTrackingAuthorizationStatus.timedOut,
    _ => AttriaxTrackingAuthorizationStatus.unknown,
  };
}
