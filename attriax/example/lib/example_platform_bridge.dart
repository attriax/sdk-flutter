import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ExampleAppLinkDomainState {
  unsupported,
  unavailable,
  verified,
  selected,
  none,
  unknown,
  error,
}

class ExampleAppLinkDomainStatus {
  const ExampleAppLinkDomainStatus({
    required this.host,
    required this.state,
    required this.details,
    required this.linkHandlingAllowed,
    required this.canOpenSettings,
  });

  factory ExampleAppLinkDomainStatus.initial(String host) {
    return ExampleAppLinkDomainStatus(
      host: host,
      state: ExampleAppLinkDomainState.unavailable,
      details: 'Checking Android app-link status...',
      linkHandlingAllowed: false,
      canOpenSettings: false,
    );
  }

  final String host;
  final ExampleAppLinkDomainState state;
  final String details;
  final bool linkHandlingAllowed;
  final bool canOpenSettings;

  bool get isVerified => state == ExampleAppLinkDomainState.verified;

  bool get needsAttention =>
      state == ExampleAppLinkDomainState.none ||
      state == ExampleAppLinkDomainState.selected ||
      state == ExampleAppLinkDomainState.unknown ||
      state == ExampleAppLinkDomainState.error;
}

abstract class ExamplePlatformBridge {
  Future<ExampleAppLinkDomainStatus> getAppLinkStatus({required String host});

  Future<bool> openAppLinkSettings();

  Future<bool> triggerNativeCrash();
}

class MethodChannelExamplePlatformBridge implements ExamplePlatformBridge {
  MethodChannelExamplePlatformBridge();

  static const MethodChannel _channel = MethodChannel(
    'attriax_example/platform',
  );

  @override
  Future<ExampleAppLinkDomainStatus> getAppLinkStatus({
    required String host,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return ExampleAppLinkDomainStatus(
        host: host,
        state: ExampleAppLinkDomainState.unsupported,
        details:
            'This status is implemented for Android because Android App Links expose a verification API.',
        linkHandlingAllowed: false,
        canOpenSettings: false,
      );
    }

    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(
        'getAppLinkStatus',
        <String, Object?>{'host': host},
      );

      return ExampleAppLinkDomainStatus(
        host: raw?['host'] as String? ?? host,
        state: _parseState(raw?['state'] as String?),
        details: raw?['details'] as String? ?? 'No details returned.',
        linkHandlingAllowed: raw?['linkHandlingAllowed'] as bool? ?? false,
        canOpenSettings: raw?['canOpenSettings'] as bool? ?? true,
      );
    } on MissingPluginException {
      return ExampleAppLinkDomainStatus(
        host: host,
        state: ExampleAppLinkDomainState.unavailable,
        details:
            'The Android example host has not exposed the app-link status channel yet.',
        linkHandlingAllowed: false,
        canOpenSettings: false,
      );
    } catch (error) {
      return ExampleAppLinkDomainStatus(
        host: host,
        state: ExampleAppLinkDomainState.error,
        details: error.toString(),
        linkHandlingAllowed: false,
        canOpenSettings: true,
      );
    }
  }

  @override
  Future<bool> openAppLinkSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>('openAppLinkSettings') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> triggerNativeCrash() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>('triggerNativeCrash') ?? true;
    } catch (_) {
      return false;
    }
  }

  ExampleAppLinkDomainState _parseState(String? value) {
    switch (value) {
      case 'verified':
        return ExampleAppLinkDomainState.verified;
      case 'selected':
        return ExampleAppLinkDomainState.selected;
      case 'none':
        return ExampleAppLinkDomainState.none;
      case 'unsupported':
        return ExampleAppLinkDomainState.unsupported;
      case 'unavailable':
        return ExampleAppLinkDomainState.unavailable;
      case 'error':
        return ExampleAppLinkDomainState.error;
      default:
        return ExampleAppLinkDomainState.unknown;
    }
  }
}
