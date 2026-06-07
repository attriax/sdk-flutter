part of 'attriax.dart';

/// Deep-link state and subscriptions exposed by [Attriax].
///
/// These helpers cover both regular incoming links and deferred deep links that
/// resolve later from app-open tracking.
class AttriaxDeepLinks {
  AttriaxDeepLinks._(this._runtime);

  final AttriaxRuntime _runtime;

  /// Launch raw deep-link event captured during startup, when one was present.
  AttriaxRawDeepLinkEvent? get rawInitialDeepLink =>
      _runtime.rawInitialDeepLink;

  /// Broadcast stream of raw deep-link inputs from native platform capture.
  Stream<AttriaxRawDeepLinkEvent> get rawStream => _runtime.rawDeepLinks;

  /// Broadcast stream of handled deep-link events.
  ///
  /// Automatic incoming links emit here after Attriax resolves them.
  /// Deferred app-open matches are also emitted here.
  Stream<AttriaxDeepLinkEvent> get stream => _runtime.deepLinks;

  /// Most recent handled deep-link event seen by the SDK.
  AttriaxDeepLinkEvent? get latestDeepLink => _runtime.latestDeepLink;

  /// Launch deep-link event captured during startup, when one was present.
  ///
  /// This stays `null` until the initial-link probe completes. Use
  /// [initialDeepLinkResolved] to distinguish "not resolved yet" from "resolved
  /// and no initial deep link was found".
  AttriaxDeepLinkEvent? get initialDeepLink => _runtime.initialDeepLink;

  /// Whether the initial deep-link probe has completed for this app session.
  bool get initialDeepLinkResolved => _runtime.isInitialDeepLinkResolved;

  /// Waits for the initial deep-link probe to finish if it is still pending.
  ///
  /// This resolves to the launch deep-link event, or `null` when no initial
  /// deep link was present.
  Future<AttriaxDeepLinkEvent?> waitForInitialDeepLink() =>
      _runtime.waitForInitialDeepLink();

  /// Waits for the resolved deep-link event corresponding to [rawEvent].
  Future<AttriaxDeepLinkEvent> waitResolution(
    AttriaxRawDeepLinkEvent rawEvent,
  ) => _runtime.waitForDeepLinkResolution(rawEvent);

  /// Creates a short dynamic link that can carry optional routing data.
  ///
  /// Attriax generates the final short code server-side, applies app-level
  /// defaults for omitted destination and Open Graph fields, and returns the
  /// shareable short URL together with the persisted link metadata.
  ///
  /// Links use the project's Attriax subdomain and optional prefix, for
  /// example `https://your-subdomain.attriax.com/prefixabc123`.
  ///
  /// [redirects] controls whether the generated link should use project
  /// redirect behavior for iOS and Android. Leave a platform value `null` to
  /// use the server default for that platform.
  Future<AttriaxCreateDynamicLinkResult> createDynamicLink({
    String? name,
    String? destinationUrl,
    String? group,
    String? prefix,
    AttriaxDynamicLinkSocialPreview? socialPreview,
    AttriaxDynamicLinkUtms? utms,
    AttriaxDynamicLinkRedirects? redirects,
    Map<String, Object?>? data,
  }) => _runtime.createDynamicLink(
    name: name,
    destinationUrl: destinationUrl,
    group: group,
    prefix: prefix,
    socialPreview: socialPreview,
    utms: utms,
    redirects: redirects,
    data: data,
  );

  /// Records a deep link manually without emitting it through the deep-link stream.
  ///
  /// Use this when your app router receives a URI before the SDK can capture it
  /// automatically. [metadata] accepts regular JSON-compatible Dart values and
  /// is sent with the resolution request.
  ///
  /// Returns the completed backend deep-link event. When Attriax does not
  /// recognize the link, the returned event still completes with `found == false`.
  Future<AttriaxDeepLinkEvent?> recordDeepLink({
    required Uri uri,
    Map<String, Object?>? metadata,
    String source = 'manual',
  }) => _runtime.recordDeepLink(uri: uri, metadata: metadata, source: source);
}
