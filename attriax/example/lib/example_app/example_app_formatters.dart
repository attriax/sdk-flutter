import 'dart:convert';

import 'package:attriax_flutter/attriax_flutter.dart';

import '../example_platform_bridge.dart';
import '../example_push_tokens.dart';

String formatExampleError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

String describeExampleSynchronizationState(AttriaxSynchronizationState state) {
  switch (state) {
    case AttriaxSynchronizationState.initializing:
      return 'Initializing';
    case AttriaxSynchronizationState.synchronizing:
      return 'Synchronizing';
    case AttriaxSynchronizationState.deferred:
      return 'Deferred queue';
    case AttriaxSynchronizationState.synchronized:
      return 'Synchronized';
    case AttriaxSynchronizationState.offline:
      return 'Offline';
    case AttriaxSynchronizationState.failed:
      return 'Failed';
    case AttriaxSynchronizationState.disabled:
      return 'Disabled';
  }
}

String describeExampleDomainState(ExampleAppLinkDomainState state) {
  switch (state) {
    case ExampleAppLinkDomainState.unsupported:
      return 'Unsupported';
    case ExampleAppLinkDomainState.unavailable:
      return 'Unavailable';
    case ExampleAppLinkDomainState.verified:
      return 'Verified';
    case ExampleAppLinkDomainState.selected:
      return 'Selected by user';
    case ExampleAppLinkDomainState.none:
      return 'Not verified';
    case ExampleAppLinkDomainState.unknown:
      return 'Unknown';
    case ExampleAppLinkDomainState.error:
      return 'Error';
  }
}

String describeExamplePushPhase(ExamplePushTokenPhase phase) {
  switch (phase) {
    case ExamplePushTokenPhase.idle:
      return 'Idle';
    case ExamplePushTokenPhase.checking:
      return 'Checking';
    case ExamplePushTokenPhase.needsPermission:
      return 'Needs permission';
    case ExamplePushTokenPhase.ready:
      return 'Ready';
    case ExamplePushTokenPhase.unavailable:
      return 'Unavailable';
    case ExamplePushTokenPhase.error:
      return 'Error';
  }
}

String describeExampleInstallReferrer(AttriaxInstallReferrerDetails? details) {
  if (details == null) {
    return 'None yet';
  }

  final campaign = details.campaign ?? 'no campaign';
  final source = details.source ?? 'unknown source';
  return '${details.attributionType.name} · $source · $campaign';
}

String describeExampleResolution(AttriaxDeepLinkResolution? resolution) {
  if (resolution == null) {
    return 'No resolution yet';
  }

  return resolution.found
      ? 'Matched ${resolution.uri}'
      : 'Recorded ${resolution.uri} without a match';
}

String formatExampleTimestamp(DateTime value) {
  final local = value.toLocal().toIso8601String();
  return local.replaceFirst('T', ' ').split('.').first;
}

String formatExampleMoney(num value, String currency) =>
    '$currency ${_trimExampleZeros(value.toStringAsFixed(2))}';

String formatExampleUsdFromMicros(int micros) =>
    'USD ${_trimExampleZeros((micros / 1000000).toStringAsFixed(6))}';

String formatExampleMicros(int micros) => '$micros micros';

String prettyExampleJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  try {
    return encoder.convert(value);
  } catch (_) {
    return value.toString();
  }
}

String shortExampleJson(Object? value) {
  try {
    final text = jsonEncode(value);
    return text.length <= 80 ? text : '${text.substring(0, 77)}...';
  } catch (_) {
    return value.toString();
  }
}

String deepLinkEventKey(AttriaxDeepLinkEvent event) =>
    '${event.uri}|${event.receivedAt.toIso8601String()}|${event.trigger.name}';

String _trimExampleZeros(String value) =>
    value.replaceFirst(RegExp(r'([.]\d*?[1-9])0+$|[.]0+$'), r'$1');
