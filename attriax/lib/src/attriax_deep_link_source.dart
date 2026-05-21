import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform-agnostic deep-link source consumed by the SDK runtime.
abstract class AttriaxDeepLinkSource {
  /// Returns the launch deep link when the host app was opened from a link.
  Future<Uri?> getInitialLink();

  /// Broadcast stream of subsequent incoming deep links.
  Stream<Uri> get uriLinkStream;
}

/// Creates the default deep-link source backed by Attriax's platform bridges.
AttriaxDeepLinkSource createDefaultAttriaxDeepLinkSource() =>
    _DefaultAttriaxDeepLinkSource();

@visibleForTesting
bool attriaxShouldIgnoreAutomaticWebInitialUri(Uri uri) {
  if (!uri.isScheme('http') && !uri.isScheme('https')) {
    return false;
  }

  final normalizedPath = uri.path.trim();
  if (normalizedPath.isNotEmpty && normalizedPath != '/') {
    return false;
  }

  return uri.fragment.trim().startsWith('/');
}

class _DefaultAttriaxDeepLinkSource implements AttriaxDeepLinkSource {
  static const MethodChannel _methodChannel = MethodChannel('attriax');
  static const EventChannel _eventChannel = EventChannel(
    'attriax/deep_links/events',
  );

  Stream<Uri>? _uriLinkStream;

  @override
  Future<Uri?> getInitialLink() async {
    if (kIsWeb) {
      final uri = _parseUri(Uri.base.toString());
      if (uri != null && attriaxShouldIgnoreAutomaticWebInitialUri(uri)) {
        return null;
      }
      return uri;
    }

    if (!_supportsAutomaticPlatformDeepLinks) {
      return null;
    }

    try {
      final rawLink = await _methodChannel.invokeMethod<String>(
        'getInitialLink',
      );
      return _parseUri(rawLink);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Stream<Uri> get uriLinkStream {
    if (kIsWeb || !_supportsAutomaticPlatformDeepLinks) {
      return const Stream<Uri>.empty();
    }

    return _uriLinkStream ??= _eventChannel.receiveBroadcastStream().map((
      event,
    ) {
      final uri = _parseUri(event);
      if (uri == null) {
        throw const FormatException('Invalid deep-link event.');
      }
      return uri;
    });
  }

  bool get _supportsAutomaticPlatformDeepLinks {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  Uri? _parseUri(Object? rawLink) {
    if (rawLink is! String) {
      return null;
    }

    final trimmed = rawLink.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return Uri.tryParse(trimmed);
  }
}
