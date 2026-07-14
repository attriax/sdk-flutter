# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "attriax_flutter_windows")
project(${PROJECT_NAME} LANGUAGES CXX)

# This is an FFI plugin: it ships NO compiled C/C++ of its own. The Windows
# binding is pure `dart:ffi` over the prebuilt Attriax KMP core C-ABI shared
# library (`attriax_core.dll`, produced by
# `:core:linkAttriax_coreReleaseSharedMingwX64` in the sibling `sdk-kmp` repo).
#
# All this build has to do is bundle that DLL alongside the application
# executable so `DynamicLibrary.open('attriax_core.dll')` resolves at runtime
# (the Windows loader searches the executable's directory). Flutter aggregates
# every plugin's `<name>_bundled_libraries` and installs them into the bundle.
set(attriax_flutter_windows_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/attriax_core.dll"
  PARENT_SCOPE
)
