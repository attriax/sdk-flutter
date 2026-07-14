# The Flutter tooling requires that developers have CMake 3.13 or later
# installed. You should not increase this version, as doing so will cause the
# plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.13)

# Project-level configuration.
set(PROJECT_NAME "attriax_flutter_linux")
project(${PROJECT_NAME} LANGUAGES CXX)

# This is an FFI plugin: it ships NO compiled C/C++ of its own. The Linux
# binding is pure `dart:ffi` over the prebuilt Attriax KMP core C-ABI shared
# library (`libattriax_core.so`, produced by
# `:core:linkAttriax_coreReleaseSharedLinuxX64` in the sibling `sdk-kmp` repo).
#
# All this build has to do is bundle that .so into the application bundle so
# `DynamicLibrary.open('libattriax_core.so')` resolves at runtime. Flutter
# installs each plugin's `<name>_bundled_libraries` into the bundle's `lib/`
# directory, and the Flutter Linux runner is linked with an `$ORIGIN/lib`
# RPATH, so the bare file name resolves.
set(attriax_flutter_linux_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/libattriax_core.so"
  PARENT_SCOPE
)
