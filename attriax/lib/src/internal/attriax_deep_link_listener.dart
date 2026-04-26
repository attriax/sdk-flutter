import 'dart:async';

import '../attriax_deep_link_source.dart';

/// Subscribes to incoming deep links, deduplicates near-simultaneous
/// deliveries of the same URI, and forwards each unique link to a callback.
class AttriaxDeepLinkListener {
  AttriaxDeepLinkListener({required AttriaxDeepLinkSource deepLinkSource})
    : _deepLinkSource = deepLinkSource;

  final AttriaxDeepLinkSource _deepLinkSource;

  StreamSubscription<Uri>? _subscription;
  Uri? _lastHandledUri;
  DateTime? _lastHandledAt;

  bool get isListening => _subscription != null;

  Future<void> start(
    Future<void> Function(Uri uri, {required bool isInitialLink}) onLink,
  ) async {
    if (_subscription != null) {
      return;
    }

    final initialLink = await _deepLinkSource.getInitialLink();
    if (initialLink != null && !_isDuplicate(initialLink)) {
      await onLink(initialLink, isInitialLink: true);
    }

    _subscription = _deepLinkSource.uriLinkStream.listen((uri) {
      // Capture isInitialLink before _isDuplicate() updates _lastHandledUri.
      final isInitialLink = _lastHandledUri == null;
      if (!_isDuplicate(uri)) {
        unawaited(onLink(uri, isInitialLink: isInitialLink));
      }
    }, onError: (_) {});
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  bool _isDuplicate(Uri uri) {
    final now = DateTime.now().toUtc();
    final prevUri = _lastHandledUri;
    final prevAt = _lastHandledAt;
    _lastHandledUri = uri;
    _lastHandledAt = now;
    return prevUri?.toString() == uri.toString() &&
        prevAt != null &&
        now.difference(prevAt) < const Duration(seconds: 2);
  }
}
