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

String? _normalizeString(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
