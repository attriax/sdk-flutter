import 'dart:ffi';

import 'package:ffi/ffi.dart';

/// C-ABI signature of the engine event callback the KMP core invokes for
/// synchronization-state transitions and resolved deep-link events.
///
/// The `eventJson` pointer is a NUL-terminated UTF-8 string owned by the engine;
/// see `AttriaxWindows` for the lifetime caveat when it is delivered through a
/// `NativeCallable.listener` (asynchronous, cross-thread) trampoline.
typedef AttriaxEventCallbackC =
    Void Function(Pointer<Utf8> eventJson, Pointer<Void> userData);

/// Thin `dart:ffi` binding over the five exported functions of the Attriax KMP
/// core C-ABI (`attriax_core.dll`), matching
/// `sdk-kmp/.../AttriaxCApi.kt`:
///
/// ```c
/// void*  attriax_create(const char* configJson, const char* dataDir);
/// char*  attriax_dispatch(void* handle, const char* method, const char* argsJson);
/// void   attriax_register_event_callback(void* handle,
///          void (*callback)(const char* eventJson, void* userData), void* userData);
/// void   attriax_free_string(char* ptr);
/// void   attriax_destroy(void* handle);
/// ```
///
/// Every `char*` returned by [dispatch] is heap-allocated by the engine and MUST
/// be released with [freeString]; the higher layer (`AttriaxWindows`) owns that
/// lifecycle.
class AttriaxCoreBindings {
  AttriaxCoreBindings(DynamicLibrary library)
    : create = library
          .lookupFunction<
            Pointer<Void> Function(Pointer<Utf8>, Pointer<Utf8>),
            Pointer<Void> Function(Pointer<Utf8>, Pointer<Utf8>)
          >('attriax_create'),
      dispatch = library
          .lookupFunction<
            Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>),
            Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>)
          >('attriax_dispatch'),
      registerEventCallback = library
          .lookupFunction<
            Void Function(
              Pointer<Void>,
              Pointer<NativeFunction<AttriaxEventCallbackC>>,
              Pointer<Void>,
            ),
            void Function(
              Pointer<Void>,
              Pointer<NativeFunction<AttriaxEventCallbackC>>,
              Pointer<Void>,
            )
          >('attriax_register_event_callback'),
      freeString = library
          .lookupFunction<
            Void Function(Pointer<Utf8>),
            void Function(Pointer<Utf8>)
          >('attriax_free_string'),
      destroy = library
          .lookupFunction<
            Void Function(Pointer<Void>),
            void Function(Pointer<Void>)
          >('attriax_destroy');

  /// Loads the bundled `attriax_core.dll` from the default library search path.
  ///
  /// Flutter bundles the DLL next to the application executable (see the
  /// plugin's `windows/CMakeLists.txt`), and the Windows loader searches the
  /// executable directory, so the bare file name resolves at runtime.
  factory AttriaxCoreBindings.open({String libraryName = 'attriax_core.dll'}) =>
      AttriaxCoreBindings(DynamicLibrary.open(libraryName));

  /// `attriax_create(configJson, dataDir) -> handle`.
  final Pointer<Void> Function(Pointer<Utf8> configJson, Pointer<Utf8> dataDir)
  create;

  /// `attriax_dispatch(handle, method, argsJson) -> resultJson`.
  final Pointer<Utf8> Function(
    Pointer<Void> handle,
    Pointer<Utf8> method,
    Pointer<Utf8> argsJson,
  )
  dispatch;

  /// `attriax_register_event_callback(handle, callback, userData)`.
  final void Function(
    Pointer<Void> handle,
    Pointer<NativeFunction<AttriaxEventCallbackC>> callback,
    Pointer<Void> userData,
  )
  registerEventCallback;

  /// `attriax_free_string(ptr)` — releases a string returned by [dispatch].
  final void Function(Pointer<Utf8> ptr) freeString;

  /// `attriax_destroy(handle)` — disposes the engine behind the handle.
  final void Function(Pointer<Void> handle) destroy;
}
