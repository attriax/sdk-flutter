/// Common analytics event names used by Attriax helpers and SKAN schemas.
///
/// Prefer these constants when wiring events that should stay consistent across
/// dashboard funnels, SKAN rules, and future SDKs. They cover the core
/// conversion steps Attriax expects most apps to care about without trying to
/// mirror every event name from third-party analytics products.
abstract final class AttriaxAnalyticsEventKeys {
  const AttriaxAnalyticsEventKeys._();

  /// Account creation completed.
  static const String signUp = 'sign_up';

  /// Authenticated session started for an existing user.
  static const String login = 'login';

  /// Onboarding or tutorial flow started.
  static const String tutorialBegin = 'tutorial_begin';

  /// Onboarding or tutorial flow completed.
  static const String tutorialComplete = 'tutorial_complete';

  /// Gameplay level or stage started.
  static const String levelStart = 'level_start';

  /// Gameplay level or stage completed.
  static const String levelComplete = 'level_complete';

  /// Player or account advanced to a higher long-term level milestone.
  static const String levelUp = 'level_up';

  /// Billing or payment credentials were submitted during checkout.
  static const String addPaymentInfo = 'add_payment_info';

  /// Purchase candidate added to a cart or basket.
  static const String addToCart = 'add_to_cart';

  /// Checkout or paywall confirmation flow started.
  static const String checkoutStarted = 'checkout_started';

  /// Revenue-generating purchase completed.
  static const String purchase = 'purchase';

  /// Purchase was refunded, revoked, or charged back.
  static const String refund = 'refund';

  /// First paid subscription period started.
  static const String subscriptionStarted = 'subscription_started';

  /// Existing subscription renewed into another paid period.
  static const String subscriptionRenewed = 'subscription_renewed';

  /// Free trial or intro offer started.
  static const String trialStarted = 'trial_started';

  /// Ad request initiated.
  static const String adRequest = 'ad_request';

  /// Ad loaded successfully.
  static const String adLoad = 'ad_load';

  /// Ad failed to load.
  static const String adLoadFailed = 'ad_load_failed';

  /// Ad presentation started.
  static const String adShow = 'ad_show';

  /// Ad failed to show after load.
  static const String adShowFailed = 'ad_show_failed';

  /// Ad impression became billable or viewable.
  static const String adImpression = 'ad_impression';

  /// Ad was clicked or tapped.
  static const String adClick = 'ad_click';

  /// Ad was dismissed or closed.
  static const String adDismiss = 'ad_dismiss';

  /// User earned an ad-based reward.
  static const String adReward = 'ad_reward';

  /// Ad monetization callback delivered realized revenue.
  static const String adRevenue = 'ad_revenue';

  /// Manual or automatic page or screen view.
  static const String pageView = 'page_view';
}

/// Common analytics payload keys used by Attriax helpers and SKAN schemas.
///
/// These keys are intentionally generic so the same payload shape can be reused
/// in regular event tracking, standardized helpers, and SKAN rule conditions.
abstract final class AttriaxAnalyticsParamKeys {
  const AttriaxAnalyticsParamKeys._();

  /// Normalized monetary amount in the supplied currency.
  static const String revenue = 'revenue';

  /// ISO 4217 currency code such as USD or EUR.
  static const String currency = 'currency';

  /// True when [revenue] is already expressed in micros.
  static const String revenueInMicros = 'revenueInMicros';

  /// Revenue subtype such as purchase or refund.
  static const String revenueType = 'revenueType';

  /// Purchase classification such as one_time, subscription, or consumable.
  static const String purchaseType = 'purchaseType';

  /// Payment or auth method used for the conversion step.
  static const String method = 'method';

  /// Payment instrument or billing type submitted at checkout.
  static const String paymentType = 'paymentType';

  /// Store product, SKU, or catalog identifier.
  static const String productId = 'productId';

  /// Store transaction or order identifier.
  static const String transactionId = 'transactionId';

  /// Original transaction identifier for subscription roots or restores.
  static const String originalTransactionId = 'originalTransactionId';

  /// Receipt-validation provider identifier.
  static const String validationProvider = 'validationProvider';

  /// Validation environment such as sandbox or production.
  static const String validationEnvironment = 'validationEnvironment';

  /// Play Billing or store-specific purchase token.
  static const String purchaseToken = 'purchaseToken';

  /// Raw receipt payload when available.
  static const String receiptData = 'receiptData';

  /// Signed store payload for provider-side verification.
  static const String signedPayload = 'signedPayload';

  /// Signature that accompanies a raw receipt payload.
  static const String receiptSignature = 'receiptSignature';

  /// Whether the transaction is a renewal of an existing subscription.
  static const String isRenewal = 'isRenewal';

  /// Purchased quantity when more than one unit was converted.
  static const String quantity = 'quantity';

  /// Storefront or platform such as app_store, play_store, or stripe.
  static const String store = 'store';

  /// Package or bundle identifier that originated the event.
  static const String packageName = 'packageName';

  /// Whether store data reports the transaction as voided.
  static const String voided = 'voided';

  /// Whether the event came from a QA or sandbox flow.
  static const String test = 'test';

  /// Server-side validation record id linked to this revenue event.
  static const String validationId = 'validationId';

  /// Free-form failure, refund, or rejection reason.
  static const String reason = 'reason';

  /// Primary ad network or monetization source.
  static const String adNetwork = 'adNetwork';

  /// Mediation layer that brokered the ad callback.
  static const String mediationNetwork = 'mediationNetwork';

  /// Ad unit or slot identifier.
  static const String adUnitId = 'adUnitId';

  /// In-app placement where the ad was shown.
  static const String adPlacement = 'adPlacement';

  /// Ad format such as banner, interstitial, rewarded, or native.
  static const String adFormat = 'adFormat';

  /// App-defined ad subtype such as paid_event or completion reason.
  static const String adType = 'adType';

  /// Load or show failure explanation from the ad SDK.
  static const String failureReason = 'failureReason';

  /// Ad load latency in milliseconds.
  static const String loadLatencyMs = 'loadLatencyMs';

  /// Reward label such as coins or gems.
  static const String rewardType = 'rewardType';

  /// Reward amount granted for an ad completion.
  static const String rewardAmount = 'rewardAmount';

  /// Canonical page or route name.
  static const String pageName = 'pageName';

  /// Page widget, screen, or controller class name.
  static const String pageClass = 'pageClass';

  /// Human-readable page title.
  static const String pageTitle = 'pageTitle';

  /// Previous page name for simple funnel reconstruction.
  static const String previousPageName = 'previousPageName';

  /// Source label describing how the event was produced.
  static const String source = 'source';

  /// Target retention milestone day from install.
  static const String day = 'day';

  /// Actual current day from install when the retention check ran.
  static const String actualDay = 'actualDay';

  /// Retention evaluation mode such as rolling or classic.
  static const String retentionType = 'retentionType';

  /// Level index, stage number, or progression label.
  static const String level = 'level';

  /// Generic numeric or categorical event value.
  static const String value = 'value';
}
