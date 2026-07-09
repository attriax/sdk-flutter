part of 'attriax.dart';

/// Tracking, revenue, token-registration, and user helpers exposed by [Attriax].
class AttriaxTracking {
  AttriaxTracking._(this._runtime);

  final AttriaxRuntimeInterface _runtime;

  /// Whether event-style tracking is currently enabled.
  ///
  /// This affects event, revenue, ad, crash, and user-association helpers in
  /// `attriax.tracking`, but it does not disable the whole SDK runtime.
  bool get enabled => _runtime.areEventsEnabled;

  /// Updates whether event-style tracking is enabled.
  ///
  /// The runtime state flips immediately and persistence is applied
  /// asynchronously in the background.
  set enabled(bool value) => _runtime.setEventsEnabled(enabled: value);

  /// Whether GDPR-safe anonymous tracking is currently allowed.
  ///
  /// Anonymous tracking omits Attriax device identity and lets analytics,
  /// crashes, sessions, and deep-link diagnostics keep flowing while GDPR
  /// consent is unresolved or only partially granted.
  bool get anonymousTrackingEnabled => _runtime.anonymousTrackingEnabled;

  /// Updates whether GDPR-safe anonymous tracking is allowed.
  set anonymousTrackingEnabled(bool value) =>
      _runtime.setAnonymousTrackingEnabled(enabled: value);

  void recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    bool flushImmediately = false,
  }) => unawaited(
    _runtime.recordEvent(
      eventName,
      eventData: eventData,
      flushImmediately: flushImmediately,
    ),
  );

  /// Records a push-notification lifecycle event for attribution.
  ///
  /// Attriax never sends pushes itself: call this from the host app's own
  /// FCM/APNs handler, threading through any Attriax [linkId]/[campaignId]
  /// reference embedded in the notification payload. Pass the raw FCM/APNs
  /// data map as [payload] and it is preserved under a `payload` key in the
  /// notification metadata.
  ///
  /// Routes through the same offline-persisted, batched, retried queue as
  /// [recordEvent], and honors the same app-open-first / consent semantics.
  void recordNotification({
    required AttriaxNotificationEventType type,
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) => unawaited(
    _runtime.recordNotification(
      type: type,
      notificationId: notificationId,
      linkId: linkId,
      campaignId: campaignId,
      title: title,
      source: source ?? _inferNotificationSource(payload),
      metadata: _mergeNotificationMetadata(
        metadata: metadata,
        payload: payload,
      ),
      flushImmediately: flushImmediately,
    ),
  );

  /// Records that a push notification was received / displayed.
  void recordNotificationReceived({
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) => recordNotification(
    type: AttriaxNotificationEventType.received,
    notificationId: notificationId,
    linkId: linkId,
    campaignId: campaignId,
    title: title,
    source: source,
    payload: payload,
    metadata: metadata,
    flushImmediately: flushImmediately,
  );

  /// Records that a push notification was opened (tapped).
  void recordNotificationOpened({
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) => recordNotification(
    type: AttriaxNotificationEventType.opened,
    notificationId: notificationId,
    linkId: linkId,
    campaignId: campaignId,
    title: title,
    source: source,
    payload: payload,
    metadata: metadata,
    flushImmediately: flushImmediately,
  );

  /// Records that a push notification was dismissed without opening.
  void recordNotificationDismissed({
    required String notificationId,
    String? linkId,
    String? campaignId,
    String? title,
    AttriaxNotificationEventSource? source,
    Map<String, Object?>? payload,
    Map<String, Object?>? metadata,
    bool flushImmediately = false,
  }) => recordNotification(
    type: AttriaxNotificationEventType.dismissed,
    notificationId: notificationId,
    linkId: linkId,
    campaignId: campaignId,
    title: title,
    source: source,
    payload: payload,
    metadata: metadata,
    flushImmediately: flushImmediately,
  );

  void recordPurchase({
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
  }) {
    final normalizedRevenue = revenue.toDouble();
    if (!normalizedRevenue.isFinite) {
      throw ArgumentError.value(revenue, 'revenue', 'revenue must be finite.');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'quantity must be positive.',
      );
    }

    final normalizedRevenueCurrency = _normalizeRevenueCurrency(
      normalizedRevenue,
      currency,
    );

    unawaited(
      _runtime.recordEvent(
        AttriaxAnalyticsEventKeys.purchase,
        eventData: <String, Object?>{
          ...?metadata,
          AttriaxAnalyticsParamKeys.revenue: normalizedRevenueCurrency.revenue,
          AttriaxAnalyticsParamKeys.currency:
              normalizedRevenueCurrency.currency,
          if (revenueInMicros) AttriaxAnalyticsParamKeys.revenueInMicros: true,
          AttriaxAnalyticsParamKeys.purchaseType: ?_trimOrNull(purchaseType),
          AttriaxAnalyticsParamKeys.productId: ?_trimOrNull(productId),
          AttriaxAnalyticsParamKeys.transactionId: ?_trimOrNull(transactionId),
          AttriaxAnalyticsParamKeys.originalTransactionId: ?_trimOrNull(
            originalTransactionId,
          ),
          AttriaxAnalyticsParamKeys.validationProvider: ?_trimOrNull(
            validationProvider,
          ),
          AttriaxAnalyticsParamKeys.validationEnvironment: ?_trimOrNull(
            validationEnvironment,
          ),
          AttriaxAnalyticsParamKeys.purchaseToken: ?_trimOrNull(purchaseToken),
          AttriaxAnalyticsParamKeys.receiptData: ?_trimOrNull(receiptData),
          AttriaxAnalyticsParamKeys.signedPayload: ?_trimOrNull(signedPayload),
          AttriaxAnalyticsParamKeys.receiptSignature: ?_trimOrNull(
            receiptSignature,
          ),
          AttriaxAnalyticsParamKeys.isRenewal: ?isRenewal,
          if (quantity != 1) AttriaxAnalyticsParamKeys.quantity: quantity,
          AttriaxAnalyticsParamKeys.store: ?_trimOrNull(store),
          AttriaxAnalyticsParamKeys.packageName: ?_trimOrNull(packageName),
          AttriaxAnalyticsParamKeys.voided: ?voided,
          AttriaxAnalyticsParamKeys.test: ?test,
          AttriaxAnalyticsParamKeys.validationId: ?_trimOrNull(validationId),
        },
        flushImmediately: flushImmediately,
      ),
    );
  }

  void recordRefund({
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
  }) {
    final normalizedRevenue = revenue.toDouble();
    if (!normalizedRevenue.isFinite) {
      throw ArgumentError.value(revenue, 'revenue', 'revenue must be finite.');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'quantity must be positive.',
      );
    }

    final normalizedRevenueCurrency = _normalizeRevenueCurrency(
      normalizedRevenue,
      currency,
    );
    final refundRevenue = normalizedRevenueCurrency.revenue == 0
        ? 0
        : -normalizedRevenueCurrency.revenue.abs();

    unawaited(
      _runtime.recordEvent(
        AttriaxAnalyticsEventKeys.refund,
        eventData: <String, Object?>{
          ...?metadata,
          AttriaxAnalyticsParamKeys.revenue: refundRevenue,
          AttriaxAnalyticsParamKeys.currency:
              normalizedRevenueCurrency.currency,
          AttriaxAnalyticsParamKeys.revenueType:
              AttriaxAnalyticsEventKeys.refund,
          if (revenueInMicros) AttriaxAnalyticsParamKeys.revenueInMicros: true,
          AttriaxAnalyticsParamKeys.purchaseType: ?_trimOrNull(purchaseType),
          AttriaxAnalyticsParamKeys.productId: ?_trimOrNull(productId),
          AttriaxAnalyticsParamKeys.transactionId: ?_trimOrNull(transactionId),
          AttriaxAnalyticsParamKeys.originalTransactionId: ?_trimOrNull(
            originalTransactionId,
          ),
          if (quantity != 1) AttriaxAnalyticsParamKeys.quantity: quantity,
          AttriaxAnalyticsParamKeys.store: ?_trimOrNull(store),
          AttriaxAnalyticsParamKeys.packageName: ?_trimOrNull(packageName),
          AttriaxAnalyticsParamKeys.voided: ?voided,
          AttriaxAnalyticsParamKeys.test: ?test,
          AttriaxAnalyticsParamKeys.reason: ?_trimOrNull(reason),
        },
        flushImmediately: flushImmediately,
      ),
    );
  }

  Future<void> registerFirebaseMessagingToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) =>
      _runtime.registerFirebaseMessagingToken(token: token, metadata: metadata);

  Future<void> registerApplePushToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) => _runtime.registerApplePushToken(token: token, metadata: metadata);

  void recordAdRevenue({
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
  }) {
    final normalizedRevenue = revenue.toDouble();
    if (!normalizedRevenue.isFinite) {
      throw ArgumentError.value(revenue, 'revenue', 'revenue must be finite.');
    }

    final normalizedRevenueCurrency = _normalizeRevenueCurrency(
      normalizedRevenue,
      currency,
    );

    unawaited(
      _runtime.recordEvent(
        AttriaxAnalyticsEventKeys.adRevenue,
        eventData: <String, Object?>{
          ...?metadata,
          AttriaxAnalyticsParamKeys.revenue: normalizedRevenueCurrency.revenue,
          AttriaxAnalyticsParamKeys.currency:
              normalizedRevenueCurrency.currency,
          if (revenueInMicros) AttriaxAnalyticsParamKeys.revenueInMicros: true,
          AttriaxAnalyticsParamKeys.adNetwork: ?_trimOrNull(adNetwork),
          AttriaxAnalyticsParamKeys.adFormat: ?_trimOrNull(adFormat),
          AttriaxAnalyticsParamKeys.adType: ?_trimOrNull(adType),
          AttriaxAnalyticsParamKeys.adPlacement: ?_trimOrNull(adPlacement),
          AttriaxAnalyticsParamKeys.test: ?test,
        },
        flushImmediately: flushImmediately,
      ),
    );
  }

  void recordAdEvent(
    AttriaxAdEventType type, {
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
  }) {
    final normalizedLoadLatencyMs = loadLatencyMs?.toDouble();
    if (normalizedLoadLatencyMs != null && !normalizedLoadLatencyMs.isFinite) {
      throw ArgumentError.value(
        loadLatencyMs,
        'loadLatencyMs',
        'loadLatencyMs must be finite.',
      );
    }

    final normalizedRewardAmount = rewardAmount?.toDouble();
    if (normalizedRewardAmount != null && !normalizedRewardAmount.isFinite) {
      throw ArgumentError.value(
        rewardAmount,
        'rewardAmount',
        'rewardAmount must be finite.',
      );
    }

    unawaited(
      _runtime.recordEvent(
        type.eventName,
        eventData: <String, Object?>{
          ...?metadata,
          AttriaxAnalyticsParamKeys.adNetwork: ?_trimOrNull(adNetwork),
          AttriaxAnalyticsParamKeys.mediationNetwork: ?_trimOrNull(
            mediationNetwork,
          ),
          AttriaxAnalyticsParamKeys.adUnitId: ?_trimOrNull(adUnitId),
          AttriaxAnalyticsParamKeys.adPlacement: ?_trimOrNull(adPlacement),
          AttriaxAnalyticsParamKeys.adFormat: ?_trimOrNull(adFormat),
          AttriaxAnalyticsParamKeys.adType: ?_trimOrNull(adType),
          AttriaxAnalyticsParamKeys.failureReason: ?_trimOrNull(failureReason),
          AttriaxAnalyticsParamKeys.rewardType: ?_trimOrNull(rewardType),
          AttriaxAnalyticsParamKeys.loadLatencyMs: ?normalizedLoadLatencyMs,
          AttriaxAnalyticsParamKeys.rewardAmount: ?normalizedRewardAmount,
          AttriaxAnalyticsParamKeys.test: ?test,
        },
        flushImmediately: flushImmediately,
      ),
    );
  }

  void recordPageView(
    String pageName, {
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
    String source = 'manual',
    bool flushImmediately = false,
  }) => unawaited(
    _runtime.recordPageView(
      pageName,
      pageClass: pageClass,
      pageTitle: pageTitle,
      previousPageName: previousPageName,
      parameters: parameters,
      source: source,
      flushImmediately: flushImmediately,
    ),
  );

  void recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String source = 'manual',
    String? reason,
    Map<String, Object?>? metadata,
  }) => unawaited(
    _runtime.recordError(
      error,
      stackTrace,
      fatal: fatal,
      source: source,
      reason: reason,
      metadata: metadata,
    ),
  );

  void setUser(String? userId, {String? userName}) =>
      unawaited(_runtime.setUser(userId, userName: userName));

  void setUserProperty(String name, Object? value) =>
      unawaited(_runtime.setUserProperty(name, value));

  void setUserProperties(Map<String, Object?> properties) =>
      unawaited(_runtime.setUserProperties(properties));

  void clearUserProperties({List<String>? propertyNames}) =>
      unawaited(_runtime.clearUserProperties(propertyNames: propertyNames));

  _AttriaxNormalizedRevenue _normalizeRevenueCurrency(
    double revenue,
    String currency,
  ) {
    final normalizedCurrency = _trimOrNull(currency)?.toUpperCase();
    if (normalizedCurrency != null &&
        RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrency)) {
      return _AttriaxNormalizedRevenue(
        revenue: revenue,
        currency: normalizedCurrency,
      );
    }

    debugPrint(
      '[Attriax][WARNING] Invalid revenue currency "$currency"; defaulting revenue to 0 USD.',
    );
    return const _AttriaxNormalizedRevenue(revenue: 0, currency: 'USD');
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Preserves the raw FCM/APNs [payload] under a `payload` key inside the
  /// notification metadata so attribution context survives the trip to the
  /// server. Explicit [metadata] entries take precedence.
  Map<String, Object?>? _mergeNotificationMetadata({
    Map<String, Object?>? metadata,
    Map<String, Object?>? payload,
  }) {
    final hasPayload = payload != null && payload.isNotEmpty;
    final hasMetadata = metadata != null && metadata.isNotEmpty;
    if (!hasPayload && !hasMetadata) {
      return metadata;
    }

    return <String, Object?>{
      if (hasPayload) 'payload': Map<String, Object?>.from(payload),
      ...?metadata,
    };
  }

  /// Best-effort inference of the delivery channel from a raw FCM/APNs
  /// [payload]. APNs payloads carry an `aps` envelope; FCM payloads carry a
  /// `google.message_id` / `gcm.message_id`. Returns `null` when undecidable so
  /// the server can fall back to `other`.
  AttriaxNotificationEventSource? _inferNotificationSource(
    Map<String, Object?>? payload,
  ) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    if (payload.containsKey('aps')) {
      return AttriaxNotificationEventSource.apns;
    }
    if (payload.keys.any(
      (key) =>
          key == 'google.message_id' ||
          key == 'gcm.message_id' ||
          key.startsWith('google.') ||
          key.startsWith('gcm.'),
    )) {
      return AttriaxNotificationEventSource.fcm;
    }
    return null;
  }
}

class _AttriaxNormalizedRevenue {
  const _AttriaxNormalizedRevenue({
    required this.revenue,
    required this.currency,
  });

  final double revenue;
  final String currency;
}
