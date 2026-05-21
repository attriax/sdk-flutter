import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

import 'attriax_web_environment_stub.dart';

extension type _NavigatorWithUserAgentData._(JSObject _) implements JSObject {
  external _NavigatorUserAgentData? get userAgentData;
}

extension type _NavigatorUserAgentData._(JSObject _) implements JSObject {
  external String? get platform;
}

@JS('Intl')
external _IntlNamespace get _intl;

extension type _IntlNamespace._(JSObject _) implements JSObject {
  // ignore: non_constant_identifier_names
  external _IntlDateTimeFormatFactory get DateTimeFormat;
}

extension type _IntlDateTimeFormatFactory._(JSFunction _)
    implements JSFunction {
  external _IntlDateTimeFormat call();
}

extension type _IntlDateTimeFormat._(JSObject _) implements JSObject {
  external _IntlResolvedOptions resolvedOptions();
}

extension type _IntlResolvedOptions._(JSObject _) implements JSObject {
  external JSString? get timeZone;
}

AttriaxWebEnvironmentSnapshot currentAttriaxWebEnvironment() {
  final assetUrl = ui_web.assetManager.getAssetUrl('');
  final navigatorWithUserAgentData = _NavigatorWithUserAgentData._(
    web.window.navigator as JSObject,
  );

  return AttriaxWebEnvironmentSnapshot(
    assetBaseUrl: _normalizeString(
      assetUrl.replaceFirst(RegExp(r'assets/$'), ''),
    ),
    documentBaseUrl: _normalizeString(web.window.document.baseURI),
    locationBaseUrl: _normalizeString(web.window.location.href),
    timezone: _resolveTimezone(),
    appName: _normalizeString(web.window.navigator.appName),
    browserName: _normalizeString(web.window.navigator.appCodeName),
    userAgent: _normalizeString(web.window.navigator.userAgent),
    platform:
        _normalizeString(navigatorWithUserAgentData.userAgentData?.platform) ??
        _normalizeString(web.window.navigator.platform),
    vendor: _normalizeString(web.window.navigator.vendor),
    title: _normalizeString(web.window.document.title),
    referrer: _normalizeString(web.window.document.referrer),
  );
}

String? _resolveTimezone() {
  try {
    return _normalizeString(
      _intl.DateTimeFormat().resolvedOptions().timeZone?.toDart,
    );
  } catch (_) {
    return null;
  }
}

String? _normalizeString(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
