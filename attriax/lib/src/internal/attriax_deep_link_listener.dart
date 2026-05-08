import 'dart:async';
import 'dart:developer' as developer;

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
  bool _initialLinkProbeCompleted = false;

  bool get isListening => _subscription != null;

  Future<void> start(
    Future<void> Function(Uri uri, {required bool isInitialLink}) onLink, {
    void Function()? onInitialLinkProbeCompleted,
  }) async {
    if (_subscription != null) {
      return;
    }

    _initialLinkProbeCompleted = false;

    _subscription = _deepLinkSource.uriLinkStream.listen(
      (uri) {
        final isInitialLink =
            !_initialLinkProbeCompleted && _lastHandledUri == null;
        if (!_isDuplicate(uri)) {
          _dispatchLink(onLink, uri, isInitialLink: isInitialLink);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        // Don't crash the SDK on a transient platform stream error, but
        // surface it through dart:developer so operators can diagnose why
        // deep-link delivery stopped (NFH3).
        developer.log(
          'Attriax deep-link stream error',
          name: 'attriax',
          level: 900,
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    unawaited(
      _dispatchInitialLink(
        onLink,
        onInitialLinkProbeCompleted: onInitialLinkProbeCompleted,
      ),
    );
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

  void _dispatchLink(
    Future<void> Function(Uri uri, {required bool isInitialLink}) onLink,
    Uri uri, {
    required bool isInitialLink,
  }) {
    unawaited(
      onLink(uri, isInitialLink: isInitialLink).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        developer.log(
          'Attriax deep-link handling error',
          name: 'attriax',
          level: 900,
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  Future<void> _dispatchInitialLink(
    Future<void> Function(Uri uri, {required bool isInitialLink}) onLink, {
    void Function()? onInitialLinkProbeCompleted,
  }) async {
    try {
      final initialLink = await _deepLinkSource.getInitialLink();
      if (initialLink != null && !_isDuplicate(initialLink)) {
        _dispatchLink(onLink, initialLink, isInitialLink: true);
      }
    } finally {
      _initialLinkProbeCompleted = true;
      onInitialLinkProbeCompleted?.call();
    }
  }
}
