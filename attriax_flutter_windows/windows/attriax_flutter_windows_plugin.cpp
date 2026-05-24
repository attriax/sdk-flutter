#include "attriax_flutter_windows_plugin.h"

#include <appmodel.h>
#include <windows.h>

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <optional>
#include <sstream>
#include <string>
#include <vector>

namespace attriax_flutter_windows {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;

constexpr char kAttriaxMethodChannelName[] = "attriax";
constexpr char kDeepLinkEventChannelName[] = "attriax/deep_links/events";

std::optional<std::string> WideToUtf8(const std::wstring& value) {
  if (value.empty()) {
    return std::nullopt;
  }

  const int size = WideCharToMultiByte(
      CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), nullptr, 0,
      nullptr, nullptr);
  if (size <= 0) {
    return std::nullopt;
  }

  std::string result(size, '\0');
  const int converted = WideCharToMultiByte(
      CP_UTF8, 0, value.c_str(), static_cast<int>(value.size()), result.data(),
      size, nullptr, nullptr);
  if (converted <= 0) {
    return std::nullopt;
  }

  return result;
}

std::optional<std::wstring> ReadRegistryString(
    HKEY root,
    const wchar_t* subkey,
    const wchar_t* value_name) {
  DWORD size = 0;
  LSTATUS status = RegGetValueW(
      root, subkey, value_name, RRF_RT_REG_SZ | RRF_RT_REG_EXPAND_SZ, nullptr,
      nullptr, &size);
  if (status != ERROR_SUCCESS || size < sizeof(wchar_t)) {
    return std::nullopt;
  }

  std::wstring buffer(size / sizeof(wchar_t), L'\0');
  status = RegGetValueW(root, subkey, value_name,
                        RRF_RT_REG_SZ | RRF_RT_REG_EXPAND_SZ, nullptr,
                        buffer.data(), &size);
  if (status != ERROR_SUCCESS) {
    return std::nullopt;
  }

  while (!buffer.empty() && buffer.back() == L'\0') {
    buffer.pop_back();
  }

  if (buffer.empty()) {
    return std::nullopt;
  }

  return buffer;
}

std::optional<std::wstring> GetComputerNameString() {
  wchar_t buffer[256];
  DWORD size = sizeof(buffer) / sizeof(buffer[0]);
  if (GetComputerNameExW(ComputerNameDnsHostname, buffer, &size) && size > 0) {
    return std::wstring(buffer, size);
  }

  size = sizeof(buffer) / sizeof(buffer[0]);
  if (GetComputerNameW(buffer, &size) && size > 0) {
    return std::wstring(buffer, size);
  }

  return std::nullopt;
}

std::optional<std::wstring> GetModulePath() {
  std::vector<wchar_t> buffer(MAX_PATH, L'\0');
  while (true) {
    const DWORD copied =
        GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
    if (copied == 0) {
      return std::nullopt;
    }

    if (copied < buffer.size() - 1) {
      return std::wstring(buffer.data(), copied);
    }

    buffer.resize(buffer.size() * 2, L'\0');
  }
}

std::optional<std::wstring> ExtractFileStem(const std::wstring& path) {
  const std::size_t separator = path.find_last_of(L"\\/");
  const std::size_t start = separator == std::wstring::npos ? 0 : separator + 1;
  const std::size_t extension = path.find_last_of(L'.');
  const std::size_t end =
      extension == std::wstring::npos || extension < start ? path.size() : extension;
  if (start >= end) {
    return std::nullopt;
  }

  return path.substr(start, end - start);
}

std::optional<std::wstring> GetCurrentPackageFamilyNameString() {
  UINT32 length = 0;
  LONG status = GetCurrentPackageFamilyName(&length, nullptr);
  if (status != ERROR_INSUFFICIENT_BUFFER || length == 0) {
    return std::nullopt;
  }

  std::wstring buffer(length, L'\0');
  status = GetCurrentPackageFamilyName(&length, buffer.data());
  if (status != ERROR_SUCCESS) {
    return std::nullopt;
  }

  while (!buffer.empty() && buffer.back() == L'\0') {
    buffer.pop_back();
  }

  if (buffer.empty()) {
    return std::nullopt;
  }

  return buffer;
}

struct ExecutableVersionInfo {
  std::string version;
  std::string build_number;
};

std::optional<ExecutableVersionInfo> GetExecutableVersionInfo() {
  const auto module_path = GetModulePath();
  if (!module_path) {
    return std::nullopt;
  }

  DWORD handle = 0;
  const DWORD info_size = GetFileVersionInfoSizeW(module_path->c_str(), &handle);
  if (info_size == 0) {
    return std::nullopt;
  }

  std::vector<unsigned char> data(info_size);
  if (!GetFileVersionInfoW(module_path->c_str(), 0, info_size, data.data())) {
    return std::nullopt;
  }

  VS_FIXEDFILEINFO* file_info = nullptr;
  UINT file_info_length = 0;
  if (!VerQueryValueW(data.data(), L"\\",
                      reinterpret_cast<void**>(&file_info),
                      &file_info_length) ||
      file_info == nullptr || file_info_length < sizeof(VS_FIXEDFILEINFO)) {
    return std::nullopt;
  }

  const auto major = HIWORD(file_info->dwFileVersionMS);
  const auto minor = LOWORD(file_info->dwFileVersionMS);
  const auto build = HIWORD(file_info->dwFileVersionLS);
  const auto revision = LOWORD(file_info->dwFileVersionLS);

  std::ostringstream version_stream;
  version_stream << major << '.' << minor << '.' << build;
  if (revision > 0) {
    version_stream << '.' << revision;
  }

  std::ostringstream build_stream;
  build_stream << build;
  if (revision > 0) {
    build_stream << '.' << revision;
  }

  return ExecutableVersionInfo{version_stream.str(), build_stream.str()};
}

std::optional<std::wstring> GetTimeZoneName() {
  DYNAMIC_TIME_ZONE_INFORMATION info = {};
  const DWORD status = GetDynamicTimeZoneInformation(&info);
  if (status == TIME_ZONE_ID_INVALID) {
    return std::nullopt;
  }

  if (info.TimeZoneKeyName[0] != L'\0') {
    return std::wstring(info.TimeZoneKeyName);
  }
  if (info.StandardName[0] != L'\0') {
    return std::wstring(info.StandardName);
  }

  return std::nullopt;
}

std::optional<int> GetColorDepth() {
  HDC screen_dc = GetDC(nullptr);
  if (screen_dc == nullptr) {
    return std::nullopt;
  }

  const int bits_per_pixel = GetDeviceCaps(screen_dc, BITSPIXEL);
  const int planes = GetDeviceCaps(screen_dc, PLANES);
  ReleaseDC(nullptr, screen_dc);

  const int color_depth = bits_per_pixel > 0 && planes > 0
                              ? bits_per_pixel * planes
                              : 0;
  if (color_depth <= 0) {
    return std::nullopt;
  }

  return color_depth;
}

std::optional<std::string> BuildWindowsOsVersion(
    const std::optional<std::wstring>& product_name,
    const std::optional<std::wstring>& display_version,
    const std::optional<std::wstring>& release_id,
    const std::optional<std::wstring>& current_build_number) {
  std::ostringstream stream;
  bool has_content = false;

  if (const auto product = product_name ? WideToUtf8(*product_name) : std::nullopt) {
    stream << *product;
    has_content = true;
  }

  const auto version = display_version
      ? WideToUtf8(*display_version)
      : (release_id ? WideToUtf8(*release_id) : std::nullopt);
  if (version) {
    if (has_content) {
      stream << ' ';
    }
    stream << *version;
    has_content = true;
  }

  if (const auto build_number =
          current_build_number ? WideToUtf8(*current_build_number) : std::nullopt) {
    if (has_content) {
      stream << " (build " << *build_number << ')';
    } else {
      stream << *build_number;
    }
    has_content = true;
  }

  if (!has_content) {
    return std::nullopt;
  }

  return stream.str();
}

void SetStringValue(
    EncodableMap& map,
    const char* key,
    const std::optional<std::string>& value) {
  if (value && !value->empty()) {
    map[EncodableValue(key)] = EncodableValue(*value);
  }
}

void SetIntegerValue(EncodableMap& map, const char* key, const std::optional<int>& value) {
  if (value) {
    map[EncodableValue(key)] = EncodableValue(*value);
  }
}

EncodableMap BuildNativeContextMetadata() {
  constexpr wchar_t kBiosKey[] = L"HARDWARE\\DESCRIPTION\\System\\BIOS";
  constexpr wchar_t kCurrentVersionKey[] =
      L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion";
  constexpr wchar_t kMachineGuidKey[] = L"SOFTWARE\\Microsoft\\Cryptography";

  EncodableMap metadata;
  metadata[EncodableValue("source")] = EncodableValue("windows_native");
  metadata[EncodableValue("isPhysicalDevice")] = EncodableValue(true);

  const auto computer_name = GetComputerNameString();
  const auto manufacturer = ReadRegistryString(HKEY_LOCAL_MACHINE, kBiosKey,
                                               L"SystemManufacturer");
  const auto product_name = ReadRegistryString(HKEY_LOCAL_MACHINE, kBiosKey,
                                               L"SystemProductName");
  const auto machine_guid =
      ReadRegistryString(HKEY_LOCAL_MACHINE, kMachineGuidKey, L"MachineGuid");
  const auto windows_product_name =
      ReadRegistryString(HKEY_LOCAL_MACHINE, kCurrentVersionKey, L"ProductName");
  const auto display_version =
      ReadRegistryString(HKEY_LOCAL_MACHINE, kCurrentVersionKey, L"DisplayVersion");
  const auto release_id =
      ReadRegistryString(HKEY_LOCAL_MACHINE, kCurrentVersionKey, L"ReleaseId");
  const auto current_build_number = ReadRegistryString(
      HKEY_LOCAL_MACHINE, kCurrentVersionKey, L"CurrentBuildNumber");
  const auto time_zone = GetTimeZoneName();
  const auto color_depth = GetColorDepth();

  const auto module_path = GetModulePath();
  const auto executable_stem =
      module_path ? ExtractFileStem(*module_path) : std::nullopt;
  const auto package_family_name = GetCurrentPackageFamilyNameString();
  const auto version_info = GetExecutableVersionInfo();

  SetStringValue(
      metadata, "computerName",
      computer_name ? WideToUtf8(*computer_name) : std::nullopt);
  SetStringValue(
      metadata, "manufacturer",
      manufacturer ? WideToUtf8(*manufacturer) : std::nullopt);
  SetStringValue(
      metadata, "productName",
      product_name ? WideToUtf8(*product_name) : std::nullopt);
  SetStringValue(metadata, "deviceId",
                 machine_guid ? WideToUtf8(*machine_guid) : std::nullopt);
  SetStringValue(
      metadata, "packageName",
      package_family_name ? WideToUtf8(*package_family_name)
                          : (executable_stem ? WideToUtf8(*executable_stem)
                                             : std::nullopt));
  SetStringValue(
      metadata, "bundleIdentifier",
      package_family_name ? WideToUtf8(*package_family_name)
                          : (executable_stem ? WideToUtf8(*executable_stem)
                                             : std::nullopt));
  SetStringValue(metadata, "appName",
                 executable_stem ? WideToUtf8(*executable_stem) : std::nullopt);
  SetStringValue(metadata, "timezone",
                 time_zone ? WideToUtf8(*time_zone) : std::nullopt);
  SetStringValue(
      metadata, "displayVersion",
      display_version ? WideToUtf8(*display_version) : std::nullopt);
  SetStringValue(metadata, "releaseId",
                 release_id ? WideToUtf8(*release_id) : std::nullopt);
  SetStringValue(metadata, "currentBuildNumber",
                 current_build_number ? WideToUtf8(*current_build_number)
                                      : std::nullopt);
  SetStringValue(metadata, "osVersion",
                 BuildWindowsOsVersion(windows_product_name, display_version,
                                       release_id, current_build_number));
  SetIntegerValue(metadata, "colorDepth", color_depth);

  if (version_info) {
    SetStringValue(metadata, "appVersion", version_info->version);
    SetStringValue(metadata, "versionName", version_info->version);
    SetStringValue(metadata, "appBuildNumber", version_info->build_number);
    SetStringValue(metadata, "buildNumber", version_info->build_number);
  }

  return metadata;
}

EncodableValue BuildNativeContextResponse() {
  EncodableMap response;
  response[EncodableValue("metadata")] = EncodableValue(BuildNativeContextMetadata());
  return EncodableValue(response);
}

EncodableValue BuildInstallReferrerResponse() {
  EncodableMap metadata;
  metadata[EncodableValue("source")] =
      EncodableValue("windows_install_referrer");
  metadata[EncodableValue("installReferrerStatus")] =
      EncodableValue("unsupported_windows");

  EncodableMap response;
  response[EncodableValue("metadata")] = EncodableValue(metadata);
  return EncodableValue(response);
}

}  // namespace

// static
void AttriaxFlutterWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kAttriaxMethodChannelName,
          &flutter::StandardMethodCodec::GetInstance());
  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), kDeepLinkEventChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AttriaxFlutterWindowsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  event_channel->SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [](const auto *arguments,
             auto &&events)
              -> std::unique_ptr<
                  flutter::StreamHandlerError<flutter::EncodableValue>> {
            return nullptr;
          },
          [](const auto *arguments)
              -> std::unique_ptr<
                  flutter::StreamHandlerError<flutter::EncodableValue>> {
            return nullptr;
          }));

  registrar->AddPlugin(std::move(plugin));
}

AttriaxFlutterWindowsPlugin::AttriaxFlutterWindowsPlugin() {}

AttriaxFlutterWindowsPlugin::~AttriaxFlutterWindowsPlugin() {}

void AttriaxFlutterWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "collectNativeContext") {
    result->Success(BuildNativeContextResponse());
    return;
  }

  if (method_call.method_name() == "collectInstallReferrer") {
    result->Success(BuildInstallReferrerResponse());
    return;
  }

  if (method_call.method_name() == "setAutomaticCrashReportingEnabled" ||
      method_call.method_name() == "consumePendingCrashReport" ||
      method_call.method_name() == "getInitialLink" ||
      method_call.method_name() == "getLatestLink") {
    result->Success();
    return;
  }

  if (method_call.method_name() == "getTrackingAuthorizationStatus" ||
      method_call.method_name() == "requestTrackingAuthorization") {
    result->Success(EncodableValue("not_supported"));
    return;
  }

  result->NotImplemented();
}

}  // namespace attriax_flutter_windows
