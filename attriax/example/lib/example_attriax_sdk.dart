import 'package:attriax/attriax.dart';
import 'package:flutter/widgets.dart';

abstract class ExampleAttriaxSdk {
  bool get isInitialized;
  bool get enabled;
  set enabled(bool value);
  bool get eventsEnabled;
  set eventsEnabled(bool value);
  bool get isFirstLaunch;
  String? get deviceId;
  AttriaxSynchronizationState get synchronizationState;
  bool get isSynchronized;
  Stream<AttriaxSynchronizationState> get synchronizationStates;
  Stream<AttriaxDeepLinkEvent> get deepLinks;

  Future<void> init();
  Future<AttriaxAppOpenResult?> waitForAppOpenTracking();
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    String? linkId,
  });
  Future<void> identify(String externalUserId, {String? externalUserName});
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    bool? iosRedirect,
    bool? androidRedirect,
    String? previewTitle,
    String? previewDescription,
    String? previewImagePath,
    Map<String, Object?>? data,
  });
  Future<AttriaxDeepLinkConversionEvent?> recordDeepLinkConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source,
  });
  List<NavigatorObserver> buildNavigatorObservers();
}

class LiveExampleAttriaxSdk implements ExampleAttriaxSdk {
  const LiveExampleAttriaxSdk(this._sdk);

  final Attriax _sdk;

  @override
  bool get isInitialized => _sdk.isInitialized;

  @override
  bool get enabled => _sdk.enabled;

  @override
  set enabled(bool value) => _sdk.enabled = value;

  @override
  bool get eventsEnabled => _sdk.eventsEnabled;

  @override
  set eventsEnabled(bool value) => _sdk.eventsEnabled = value;

  @override
  bool get isFirstLaunch => _sdk.isFirstLaunch;

  @override
  String? get deviceId => _sdk.deviceId;

  @override
  AttriaxSynchronizationState get synchronizationState =>
      _sdk.synchronization.state;

  @override
  bool get isSynchronized => _sdk.synchronization.isSynchronized;

  @override
  Stream<AttriaxSynchronizationState> get synchronizationStates =>
      _sdk.synchronization.states;

  @override
  Stream<AttriaxDeepLinkEvent> get deepLinks => _sdk.deepLinks;

  @override
  Future<void> init() => _sdk.init();

  @override
  Future<AttriaxAppOpenResult?> waitForAppOpenTracking() =>
      _sdk.waitForAppOpenTracking();

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? eventData,
    String? linkId,
  }) => _sdk.trackEvent(eventName, eventData: eventData, linkId: linkId);

  @override
  Future<void> identify(String externalUserId, {String? externalUserName}) =>
      _sdk.identify(externalUserId, externalUserName: externalUserName);

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    bool? iosRedirect,
    bool? androidRedirect,
    String? previewTitle,
    String? previewDescription,
    String? previewImagePath,
    Map<String, Object?>? data,
  }) => _sdk.createDynamicLink(
    name: name,
    destinationUrl: destinationUrl,
    group: group,
    prefix: prefix,
    iosRedirect: iosRedirect,
    androidRedirect: androidRedirect,
    previewTitle: previewTitle,
    previewDescription: previewDescription,
    previewImagePath: previewImagePath,
    data: data,
  );

  @override
  Future<AttriaxDeepLinkConversionEvent?> recordDeepLinkConversion({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) => _sdk.recordDeepLinkConversion(
    uri: uri,
    linkPath: linkPath,
    metadata: metadata,
    source: source,
  );

  @override
  List<NavigatorObserver> buildNavigatorObservers() => <NavigatorObserver>[
    AttriaxNavigationObserver(attriax: _sdk),
  ];
}
