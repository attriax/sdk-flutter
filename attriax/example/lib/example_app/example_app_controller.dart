import 'dart:async';

import 'package:attriax_flutter/attriax_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../example_app_configuration.dart';
import '../example_platform_bridge.dart';
import '../example_push_tokens.dart';
import 'example_app_formatters.dart';

class ExampleAppController extends ChangeNotifier {
  ExampleAppController({
    required this.sdk,
    ExamplePushTokenService? pushTokenService,
    ExamplePlatformBridge? platformBridge,
    TargetPlatform? targetPlatform,
  }) : _pushTokenService =
           pushTokenService ?? LiveExamplePushTokenService(sdk: sdk),
       _platformBridge = platformBridge ?? MethodChannelExamplePlatformBridge(),
       _targetPlatform = targetPlatform;

  final Attriax sdk;
  final ExamplePushTokenService _pushTokenService;
  final ExamplePlatformBridge _platformBridge;
  final TargetPlatform? _targetPlatform;

  void Function(AttriaxRawDeepLinkEvent event)? onDeepLinkNavigation;

  final List<ExampleActivityEntry> recentActivity = <ExampleActivityEntry>[];
  final Set<String> _handledDeepLinkKeys = <String>{};

  StreamSubscription<AttriaxSynchronizationState>? _syncSubscription;
  StreamSubscription<AttriaxRawDeepLinkEvent>? _deepLinkSubscription;
  StreamSubscription<ExamplePushTokenSnapshot>? _pushTokenSubscription;

  bool _started = false;
  bool _isRefreshing = false;

  String statusMessage = 'Booting the example...';
  AttriaxSynchronizationState synchronizationState =
      AttriaxSynchronizationState.initializing;
  bool enabled = true;
  bool eventsEnabled = true;
  bool isFirstLaunch = false;
  bool isInitialized = false;
  bool initialDeepLinkResolved = false;
  String? deviceId;
  AttriaxSdkSnapshot? sdkSnapshot;
  AttriaxSkanState? skanState;
  AttriaxSkanUpdateResult? lastSkanUpdateResult;
  AttriaxInstallReferrerDetails? originalInstallReferrer;
  AttriaxInstallReferrerDetails? reinstallReferrer;
  AttriaxRawDeepLinkEvent? rawInitialDeepLink;
  AttriaxRawDeepLinkEvent? latestRawDeepLink;
  AttriaxDeepLinkEvent? initialDeepLink;
  AttriaxDeepLinkEvent? latestDeepLink;
  AttriaxDeepLinkEvent? latestResolution;
  Object? latestDeepLinkError;
  AttriaxCreateDynamicLinkResult? latestCreatedLink;
  String? latestValidationSummary;
  String? latestTokenSummary;
  String gamePlayerName = 'Player One';
  ExamplePushTokenSnapshot pushTokenSnapshot =
      const ExamplePushTokenSnapshot.idle();
  ExampleAppLinkDomainStatus appLinkStatus = ExampleAppLinkDomainStatus.initial(
    exampleDeepLinkHost,
  );
  final Map<String, Map<String, int>> _bestScoresByPlayer =
      <String, Map<String, int>>{};

  bool get isRefreshing => _isRefreshing;

  bool get skanTestingAvailable =>
      !kIsWeb &&
      (_targetPlatform ?? defaultTargetPlatform) == TargetPlatform.iOS;

  String get activeGamePlayerName {
    final trimmed = gamePlayerName.trim();
    return trimmed.isEmpty ? 'Guest' : trimmed;
  }

  String get currentDeepLink =>
      latestCreatedLink?.link.shortUrl ??
      buildExampleFallbackDeepLink().toString();

  int bestScoreForGame(String gameId) =>
      _bestScoresByPlayer[activeGamePlayerName]?[gameId] ?? 0;

  void setGamePlayerName(String value) {
    if (gamePlayerName == value) {
      return;
    }

    gamePlayerName = value;
    notifyListeners();
  }

  Future<void> start() async {
    if (_started) {
      return;
    }

    _started = true;
    _syncFromSdk();
    _syncSubscription = sdk.synchronization.states.listen((state) {
      synchronizationState = state;
      _syncFromSdk();
      notifyListeners();
    });
    _deepLinkSubscription = sdk.deepLinks.rawStream.listen(
      _handleDeepLinkEvent,
    );
    _pushTokenSubscription = _pushTokenService.snapshots.listen((snapshot) {
      pushTokenSnapshot = snapshot;
      latestTokenSummary = snapshot.summary;
      _pushActivity('pushTokens', detail: snapshot.summary);
      notifyListeners();
    });
    await refreshAll();
  }

  Future<void> disposeController() async {
    await _syncSubscription?.cancel();
    await _deepLinkSubscription?.cancel();
    await _pushTokenSubscription?.cancel();
    await _pushTokenService.dispose();
  }

  Future<void> refreshAll() async {
    _isRefreshing = true;
    statusMessage = 'Refreshing SDK diagnostics...';
    notifyListeners();

    _syncFromSdk();
    initialDeepLinkResolved = sdk.deepLinks.initialDeepLinkResolved;
    rawInitialDeepLink = sdk.deepLinks.rawInitialDeepLink;
    latestRawDeepLink ??= rawInitialDeepLink;
    initialDeepLink = sdk.deepLinks.initialDeepLink;
    latestDeepLink = sdk.deepLinks.latestDeepLink;
    latestResolution = latestDeepLink;

    try {
      final initialEvent = await sdk.deepLinks.waitForInitialDeepLink();
      initialDeepLinkResolved = sdk.deepLinks.initialDeepLinkResolved;
      if (initialEvent != null) {
        initialDeepLink = initialEvent;
        latestDeepLink ??= initialEvent;
        latestResolution ??= initialEvent;
      }

      originalInstallReferrer = await sdk.referrer.getOriginalInstallReferrer(
        timeout: const Duration(milliseconds: 800),
        safe: true,
      );
      reinstallReferrer = await sdk.referrer.getReinstallReferrer(
        timeout: const Duration(milliseconds: 300),
        safe: true,
      );
      await refreshDomainStatus();
      await refreshPushTokenStatus();
      statusMessage =
          'SDK ready. Use the pages below to inspect deep links, token registration, events, and controls.';
      _pushActivity(
        'Diagnostics refreshed',
        detail: describeExampleSynchronizationState(synchronizationState),
      );
    } catch (error) {
      statusMessage =
          'Loaded with partial diagnostics: ${formatExampleError(error)}';
      _pushActivity(
        'Diagnostics refresh failed',
        detail: formatExampleError(error),
        isError: true,
      );
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> toggleSdk(bool value) async {
    sdk.enabled = value;
    enabled = value;
    synchronizationState = sdk.synchronization.state;
    statusMessage = value
        ? 'SDK enabled. Tracking and deep-link handling are active.'
        : 'SDK disabled. Tracking and deep-link handling stop until re-enabled.';
    _pushActivity('SDK ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  Future<void> toggleEvents(bool value) async {
    sdk.eventsEnabled = value;
    eventsEnabled = value;
    statusMessage = value
        ? 'Custom events are enabled.'
        : 'Custom events are disabled while attribution stays active.';
    _pushActivity('Events ${value ? 'enabled' : 'disabled'}');
    notifyListeners();
  }

  Future<void> setExampleUser(String userId, String userName) async {
    await sdk.setUser(userId, userName: userName);
    statusMessage = 'Associated the install with $userId.';
    _pushActivity('setUser', detail: '$userId ($userName)');
    notifyListeners();
  }

  Future<void> clearExampleUser() async {
    await sdk.setUser(null);
    statusMessage = 'Cleared the associated user.';
    _pushActivity('setUser', detail: 'cleared');
    notifyListeners();
  }

  Future<void> setExampleUserProperties() async {
    await sdk.setUserProperties(<String, Object?>{
      'plan': 'growth',
      'cohort': 'spring_launch',
      'notifications_enabled': true,
    });
    statusMessage = 'Stored user properties for future events.';
    _pushActivity('setUserProperties', detail: 'plan, cohort, notifications');
    notifyListeners();
  }

  Future<void> clearExampleUserProperties() async {
    await sdk.clearUserProperties();
    statusMessage = 'Cleared stored user properties.';
    _pushActivity('clearUserProperties');
    notifyListeners();
  }

  Future<void> sendCustomEvent({
    required String name,
    required Map<String, Object?> data,
  }) async {
    await sdk.recordEvent(name, eventData: data, flushImmediately: true);
    statusMessage = 'Sent $name.';
    _pushActivity(name, detail: shortExampleJson(data));
    notifyListeners();
  }

  Future<void> sendPageView({
    required String pageName,
    String? pageClass,
    String? pageTitle,
    String? previousPageName,
    Map<String, Object?>? parameters,
  }) async {
    await sdk.recordPageView(
      pageName,
      pageClass: pageClass,
      pageTitle: pageTitle,
      previousPageName: previousPageName,
      parameters: parameters,
      source: 'example_manual_button',
    );
    statusMessage = 'Recorded page_view for $pageName.';
    _pushActivity('page_view', detail: pageName);
    notifyListeners();
  }

  Future<void> sendAdLifecycle(AttriaxAdEventType type) async {
    await sdk.recordAdEvent(
      type,
      adNetwork: 'admob',
      mediationNetwork: 'example_network',
      adUnitId: 'demo_unit_01',
      adPlacement: 'rewarded_end_of_level',
      adFormat: type == AttriaxAdEventType.reward ? 'rewarded' : 'interstitial',
      rewardType: type == AttriaxAdEventType.reward ? 'coins' : null,
      rewardAmount: type == AttriaxAdEventType.reward ? 25 : null,
      loadLatencyMs: type == AttriaxAdEventType.load ? 420 : null,
      failureReason: type == AttriaxAdEventType.showFailed ? 'no_fill' : null,
    );
    statusMessage = 'Recorded ${type.eventName}.';
    _pushActivity(type.eventName, detail: 'rewarded_end_of_level');
    notifyListeners();
  }

  Future<void> sendAdRevenueExample({required int revenueMicros}) async {
    await sdk.recordAdRevenue(
      revenue: revenueMicros,
      currency: 'USD',
      revenueInMicros: true,
      adNetwork: 'admob',
      adFormat: 'rewarded',
      adType: 'paid_event',
      adPlacement: 'rewarded_end_of_level',
      metadata: <String, Object?>{
        'currency_source': 'usd',
        'example_surface': 'events_page',
        'revenueMicros': revenueMicros,
      },
    );
    statusMessage =
        'Recorded ad_revenue for ${formatExampleUsdFromMicros(revenueMicros)}.';
    _pushActivity(
      'ad_revenue',
      detail:
          '${formatExampleUsdFromMicros(revenueMicros)} (${formatExampleMicros(revenueMicros)})',
    );
    notifyListeners();
  }

  Future<void> sendPurchaseExample({
    required num revenue,
    required String currency,
  }) async {
    await sdk.recordPurchase(
      revenue: revenue,
      currency: currency,
      purchaseType: 'subscription_initial',
      productId: 'pro_monthly',
      transactionId: 'txn_demo_1001',
      originalTransactionId: 'txn_demo_root_1001',
      validationProvider: 'google_play',
      validationEnvironment: 'sandbox',
      packageName: 'com.attriax.attriax_example',
      test: true,
      metadata: const <String, Object?>{
        'paywall': 'starter_offer',
        'entry_point': 'events_page',
      },
    );
    statusMessage =
        'Recorded a demo purchase for ${formatExampleMoney(revenue, currency)}.';
    _pushActivity(
      'purchase',
      detail: 'pro_monthly / ${formatExampleMoney(revenue, currency)}',
    );
    notifyListeners();
  }

  Future<void> sendRefundExample({
    required num revenue,
    required String currency,
  }) async {
    await sdk.recordRefund(
      revenue: revenue,
      currency: currency,
      purchaseType: 'subscription_initial',
      productId: 'pro_monthly',
      transactionId: 'refund_demo_1001',
      originalTransactionId: 'txn_demo_root_1001',
      packageName: 'com.attriax.attriax_example',
      reason: 'customer_support_demo',
      test: true,
      metadata: const <String, Object?>{'entry_point': 'events_page'},
    );
    statusMessage =
        'Recorded a demo refund for ${formatExampleMoney(revenue, currency)}.';
    _pushActivity(
      'refund',
      detail: 'pro_monthly / ${formatExampleMoney(revenue, currency)}',
    );
    notifyListeners();
  }

  Future<void> validateDemoReceipt({
    required num revenue,
    required String currency,
  }) async {
    latestValidationSummary =
        'Fake Unity-style validation · approved · ${formatExampleMoney(revenue, currency)} · unity_demo_validation';
    statusMessage =
        'validateReceipt was simulated locally with a Unity-style demo response.';
    _pushActivity('validateReceipt', detail: latestValidationSummary);
    notifyListeners();
  }

  Future<void> createDemoDynamicLink({String? prefix}) async {
    final normalizedPrefix = _trimOrNull(prefix);
    latestCreatedLink = await sdk.createDynamicLink(
      name: 'Flutter example deep-link demo',
      destinationUrl: buildExampleFallbackDeepLink().toString(),
      group: exampleDeepLinkGroup,
      prefix: normalizedPrefix,
      socialPreview: const AttriaxDynamicLinkSocialPreview(
        title: 'Attriax Flutter Example',
        description: 'Open the example app and inspect the deep-link state.',
      ),
      utms: const AttriaxDynamicLinkUtms(
        source: 'flutter_example',
        medium: 'share',
        campaign: 'deeplink_demo',
        content: 'manual_create_button',
      ),
      redirects: const AttriaxDynamicLinkRedirects(ios: true, android: true),
      data: const <String, Object?>{
        'screen': 'deep_link_result',
        'source': 'flutter_example',
      },
    );
    statusMessage = normalizedPrefix == null
        ? 'Created a shareable deep link.'
        : 'Created a shareable deep link with prefix "$normalizedPrefix".';
    _pushActivity(
      'createDynamicLink',
      detail: latestCreatedLink!.link.shortUrl,
    );
    notifyListeners();
  }

  Future<void> copyLatestLink() async {
    await Clipboard.setData(ClipboardData(text: currentDeepLink));
    statusMessage = 'Copied the current deep link to the clipboard.';
    _pushActivity('Clipboard', detail: currentDeepLink);
    notifyListeners();
  }

  Future<void> noteSharedLink() async {
    statusMessage =
        'Opened the platform share sheet for the current deep link.';
    _pushActivity('Share link', detail: currentDeepLink);
    notifyListeners();
  }

  Future<void> refreshPushTokenStatus({bool requestPermission = false}) async {
    await _pushTokenService.refresh(requestPermission: requestPermission);
    latestTokenSummary = _pushTokenService.snapshot.summary;
    statusMessage = _pushTokenService.snapshot.summary;
    notifyListeners();
  }

  Future<void> refreshDomainStatus() async {
    appLinkStatus = await _platformBridge.getAppLinkStatus(
      host: exampleDeepLinkHost,
    );
    notifyListeners();
  }

  Future<void> refreshSkanState() async {
    if (!skanTestingAvailable) {
      statusMessage = 'SKAN testing is available on iOS only.';
      _pushActivity(
        'SKAN state refresh unavailable',
        detail: 'ios only',
        isError: true,
      );
      notifyListeners();
      return;
    }

    _syncFromSdk();
    statusMessage = 'Refreshed the local SKAN state snapshot.';
    _pushActivity(
      'SKAN state refreshed',
      detail:
          'fine=${skanState?.fineValue ?? 'unset'} coarse=${skanState?.coarseValue?.name ?? 'unset'}',
    );
    notifyListeners();
  }

  Future<AttriaxSkanUpdateResult?> updateSkanConversionValue({
    required int fineValue,
    AttriaxSkanCoarseValue? coarseValue,
    bool lockWindow = false,
  }) async {
    if (!skanTestingAvailable) {
      statusMessage = 'SKAN testing is available on iOS only.';
      _pushActivity(
        'SKAN update unavailable',
        detail: 'ios only',
        isError: true,
      );
      notifyListeners();
      return null;
    }

    try {
      final result = await sdk.skan.updateConversionValue(
        fineValue: fineValue,
        coarseValue: coarseValue,
        lockWindow: lockWindow,
      );

      lastSkanUpdateResult = result;
      skanState = result.state ?? sdk.skan.state;
      statusMessage = result.message == null
          ? 'SKAN update ${describeExampleSkanUpdateStatus(result.status)}.'
          : 'SKAN update ${describeExampleSkanUpdateStatus(result.status)}: ${result.message}';
      _pushActivity(
        'SKAN update',
        detail: result.message == null
            ? describeExampleSkanUpdateStatus(result.status)
            : '${describeExampleSkanUpdateStatus(result.status)}: ${result.message}',
        isError: result.status == AttriaxSkanUpdateStatus.error,
      );
      notifyListeners();
      return result;
    } catch (error) {
      statusMessage = 'SKAN update failed: ${formatExampleError(error)}';
      _pushActivity(
        'SKAN update failed',
        detail: formatExampleError(error),
        isError: true,
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<void> openAppLinkSettings() async {
    final opened = await _platformBridge.openAppLinkSettings();
    statusMessage = opened
        ? 'Opened the system settings for app-link verification.'
        : 'The current platform does not expose app-link settings from the example app.';
    _pushActivity('Open app-link settings', detail: statusMessage);
    notifyListeners();
  }

  Future<bool> triggerNativeCrashTest() async {
    final triggered = await _platformBridge.triggerNativeCrash();
    statusMessage = triggered
        ? 'Requested a native crash from the example host. The app should terminate immediately on supported platforms.'
        : 'Native crash testing is currently exposed by the Android example host only.';
    _pushActivity(
      triggered ? 'Native crash requested' : 'Native crash unavailable',
      detail: triggered ? 'android host' : 'unsupported platform',
      isError: !triggered,
    );
    notifyListeners();
    return triggered;
  }

  Future<void> recordManualDeepLink(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      statusMessage = 'Enter a path or a full URL first.';
      notifyListeners();
      return;
    }

    final parsedUri = Uri.tryParse(trimmed);
    final resolution = await sdk.recordDeepLink(
      uri: parsedUri != null && parsedUri.hasScheme ? parsedUri : null,
      linkPath: parsedUri == null || !parsedUri.hasScheme ? trimmed : null,
      metadata: const <String, Object?>{'source': 'manual_deeplink_page'},
      source: 'manual_example_page',
    );

    if (resolution == null) {
      statusMessage = 'Manual deep-link recording returned no result.';
      _pushActivity('recordDeepLink', detail: 'no result', isError: true);
    } else {
      latestResolution = resolution;
      latestDeepLink = resolution;
      statusMessage = resolution.found
          ? 'Manual deep link matched ${resolution.uri}.'
          : 'Manual deep link was recorded but not matched.';
      _pushActivity('recordDeepLink', detail: resolution.uri.toString());
    }
    notifyListeners();
  }

  Future<void> noteMiniGameStarted({required String gameId}) async {
    final playerName = activeGamePlayerName;
    await sdk.recordEvent(
      'mini_game_started',
      eventData: <String, Object?>{
        'game': gameId,
        'playerName': playerName,
        'bestScore': bestScoreForGame(gameId),
      },
      flushImmediately: true,
    );
    statusMessage = '$playerName started $gameId.';
    _pushActivity('mini_game_started', detail: '$gameId · $playerName');
    notifyListeners();
  }

  Future<void> noteMiniGameMilestone({
    required String gameId,
    required int score,
    String? label,
    Map<String, Object?> metrics = const <String, Object?>{},
  }) async {
    final playerName = activeGamePlayerName;
    await sdk.recordEvent(
      'mini_game_milestone',
      eventData: <String, Object?>{
        'game': gameId,
        'playerName': playerName,
        'score': score,
        'label': ?label,
        ...metrics,
      },
    );
    _pushActivity(
      'mini_game_milestone',
      detail:
          '$gameId · $playerName · score=$score${label == null ? '' : ' · $label'}',
    );
    notifyListeners();
  }

  Future<void> noteMiniGameFinished({
    required String gameId,
    required int score,
    Map<String, Object?> metrics = const <String, Object?>{},
  }) async {
    final playerName = activeGamePlayerName;
    final previousBest = bestScoreForGame(gameId);
    final improved = _rememberBestScore(playerName, gameId, score);
    final bestScore = improved ? score : previousBest;
    await sdk.recordEvent(
      'mini_game_finished',
      eventData: <String, Object?>{
        'game': gameId,
        'playerName': playerName,
        'score': score,
        'bestScore': bestScore,
        'newBest': improved,
        ...metrics,
      },
      flushImmediately: true,
    );
    statusMessage = improved
        ? '$playerName set a new $gameId best score of $score.'
        : '$playerName finished $gameId with $score.';
    _pushActivity(
      'mini_game_finished',
      detail:
          '$gameId · $playerName · score=$score${improved ? ' new best' : ''}',
    );
    notifyListeners();
  }

  Future<void> _handleDeepLinkEvent(AttriaxRawDeepLinkEvent event) async {
    final key = rawDeepLinkEventKey(event);
    final shouldNavigate = _handledDeepLinkKeys.add(key);

    initialDeepLinkResolved = sdk.deepLinks.initialDeepLinkResolved;
    if (event.isInitial && rawInitialDeepLink == null) {
      rawInitialDeepLink = event;
    }
    latestRawDeepLink = event;
    latestDeepLinkError = null;
    statusMessage = 'Received raw deep link ${event.uri}.';
    _pushActivity(
      'deepLinks.rawStream',
      detail: '${event.isInitial ? 'initial' : 'runtime'} ${event.uri}',
    );
    notifyListeners();

    if (shouldNavigate) {
      onDeepLinkNavigation?.call(event);
    }

    try {
      latestResolution = await sdk.deepLinks.waitResolution(event);
      latestDeepLink = latestResolution;
      if (latestResolution!.isColdStart && initialDeepLink == null) {
        initialDeepLink = latestResolution;
      }
      statusMessage = latestResolution!.found
          ? 'Deep link matched ${latestResolution!.uri}.'
          : 'Deep link recorded without a matching Attriax link.';
      _pushActivity(
        'deepLinks.waitResolution',
        detail: latestResolution!.found ? 'matched' : 'unmatched',
      );
    } catch (error) {
      latestDeepLinkError = error;
      statusMessage =
          'Deep-link resolution failed: ${formatExampleError(error)}';
      _pushActivity(
        'deepLinks.waitResolution',
        detail: formatExampleError(error),
        isError: true,
      );
    }
    notifyListeners();
  }

  void _syncFromSdk() {
    isInitialized = sdk.isInitialized;
    enabled = sdk.enabled;
    eventsEnabled = sdk.eventsEnabled;
    isFirstLaunch = sdk.isFirstLaunch;
    deviceId = sdk.deviceId;
    sdkSnapshot = sdk.sdkSnapshot;
    skanState = skanTestingAvailable ? sdk.skan.state : null;
    synchronizationState = sdk.synchronization.state;
  }

  void _pushActivity(String title, {String? detail, bool isError = false}) {
    recentActivity.insert(
      0,
      ExampleActivityEntry(
        title: title,
        detail: detail,
        at: DateTime.now(),
        isError: isError,
      ),
    );
    if (recentActivity.length > 12) {
      recentActivity.removeLast();
    }
  }

  bool _rememberBestScore(String playerName, String gameId, int score) {
    final scores = _bestScoresByPlayer.putIfAbsent(
      playerName,
      () => <String, int>{},
    );
    final previous = scores[gameId] ?? 0;
    if (score <= previous) {
      return false;
    }

    scores[gameId] = score;
    return true;
  }

  String? _trimOrNull(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class ExampleActivityEntry {
  const ExampleActivityEntry({
    required this.title,
    required this.at,
    this.detail,
    this.isError = false,
  });

  final String title;
  final DateTime at;
  final String? detail;
  final bool isError;
}
