import 'package:attriax_flutter/attriax_flutter.dart';
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
  AttriaxDeepLinks get deepLinks;
  Future<AttriaxInstallReferrerDetails?> get installReferrer;

  Future<void> init();
  Future<void> dispose();
  Future<void> recordEvent(String eventName, {Map<String, Object?>? eventData});
  Future<void> registerFirebaseMessagingToken(
    String? token, {
    Map<String, Object?>? metadata,
  });
  Future<void> registerApplePushToken(
    String? token, {
    Map<String, Object?>? metadata,
  });
  Future<void> setUser(String? userId, {String? userName});
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkRedirects? redirects,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    Map<String, Object?>? data,
  });
  Future<AttriaxDeepLinkResolution?> recordDeepLink({
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
  AttriaxDeepLinks get deepLinks => _sdk.deepLinks;

  @override
  Future<AttriaxInstallReferrerDetails?> get installReferrer =>
      _sdk.installReferrer;

  @override
  Future<void> init() => _sdk.init();

  @override
  Future<void> dispose() => _sdk.dispose();

  @override
  Future<void> recordEvent(
    String eventName, {
    Map<String, Object?>? eventData,
  }) => _sdk.recordEvent(eventName, eventData: eventData);

  @override
  Future<void> registerFirebaseMessagingToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) => _sdk.registerFirebaseMessagingToken(token, metadata: metadata);

  @override
  Future<void> registerApplePushToken(
    String? token, {
    Map<String, Object?>? metadata,
  }) => _sdk.registerApplePushToken(token, metadata: metadata);

  @override
  Future<void> setUser(String? userId, {String? userName}) =>
      _sdk.setUser(userId, userName: userName);

  @override
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkRedirects? redirects,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    Map<String, Object?>? data,
  }) => _sdk.createDynamicLink(
    name: name,
    destinationUrl: destinationUrl,
    group: group,
    prefix: prefix,
    redirects: redirects,
    socialPreview: socialPreview,
    utms: utms,
    data: data,
  );

  @override
  Future<AttriaxDeepLinkResolution?> recordDeepLink({
    Uri? uri,
    String? linkPath,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) => _sdk.recordDeepLink(
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
