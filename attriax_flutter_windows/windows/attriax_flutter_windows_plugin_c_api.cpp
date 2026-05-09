#include "include/attriax_flutter_windows/attriax_flutter_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "attriax_flutter_windows_plugin.h"

void AttriaxFlutterWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  attriax_flutter_windows::AttriaxFlutterWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
