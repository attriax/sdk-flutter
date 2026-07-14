// Loads the vendored sdk-js IIFE bundle into the page.
//
// Flutter web plugins do not auto-inject scripts, so the plugin injects a
// `<script>` tag pointing at the package asset and waits for it to attach
// `globalThis.AttriaxJs` before constructing the engine. The load is memoized so
// concurrent `initialize` calls share one injection.

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'attriax_js_interop.dart';

/// Flutter serves a package's declared assets at
/// `assets/packages/<package>/<path>`, resolved against the app base href.
const String _attriaxJsAssetUrl =
    'assets/packages/attriax_flutter_web/assets/attriax_js.js';

Future<void>? _loadFuture;

/// Ensures `globalThis.AttriaxJs` is available, injecting the vendored bundle on
/// first use. Safe to call repeatedly; the injection happens at most once.
Future<void> ensureAttriaxJsLoaded() {
  if (isAttriaxJsLoaded) {
    return Future<void>.value();
  }
  return _loadFuture ??= _injectScript();
}

Future<void> _injectScript() {
  final completer = Completer<void>();

  void onLoad(web.Event _) {
    if (completer.isCompleted) {
      return;
    }
    if (isAttriaxJsLoaded) {
      completer.complete();
    } else {
      completer.completeError(
        StateError(
          'Attriax web engine script loaded but globalThis.AttriaxJs is '
          'undefined. The vendored bundle may be corrupt.',
        ),
      );
    }
  }

  void onError(web.Event _) {
    if (!completer.isCompleted) {
      completer.completeError(
        StateError(
          'Failed to load the Attriax web engine bundle from '
          '"$_attriaxJsAssetUrl".',
        ),
      );
    }
  }

  final script = web.HTMLScriptElement()
    ..type = 'text/javascript'
    ..src = _attriaxJsAssetUrl
    ..async = true
    ..addEventListener('load', onLoad.toJS)
    ..addEventListener('error', onError.toJS);

  web.document.head!.appendChild(script);
  return completer.future;
}
