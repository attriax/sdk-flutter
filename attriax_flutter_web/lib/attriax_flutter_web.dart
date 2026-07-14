/// Web implementation of the `attriax_flutter` federated plugin.
///
/// This package binds the Flutter platform interface to the sdk-js engine
/// (`@attriax/js`) over `dart:js_interop`, so a Flutter-web build runs the same
/// wire behavior as every other Attriax SDK. It registers `AttriaxWeb` as
/// `AttriaxPlatform.instance` on the web.
library;

export 'src/attriax_web.dart' show AttriaxWeb;
