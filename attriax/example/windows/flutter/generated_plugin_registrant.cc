//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <attriax_flutter_windows/attriax_flutter_windows_plugin_c_api.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AttriaxFlutterWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AttriaxFlutterWindowsPluginCApi"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
}
