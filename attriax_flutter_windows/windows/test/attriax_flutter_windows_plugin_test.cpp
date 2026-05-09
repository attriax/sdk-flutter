#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <string>
#include <variant>

#include "attriax_flutter_windows_plugin.h"

namespace attriax_flutter_windows {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResultFunctions;

}  // namespace

TEST(AttriaxFlutterWindowsPlugin, GetPlatformVersion) {
  AttriaxFlutterWindowsPlugin plugin;
  // Save the reply value from the success callback.
  std::string result_string;
  plugin.HandleMethodCall(
      MethodCall("getPlatformVersion", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&result_string](const EncodableValue* result) {
            result_string = std::get<std::string>(*result);
          },
          nullptr, nullptr));

  // Since the exact string varies by host, just ensure that it's a string
  // with the expected format.
  EXPECT_TRUE(result_string.rfind("Windows ", 0) == 0);
}

TEST(AttriaxFlutterWindowsPlugin, CollectNativeContext) {
  AttriaxFlutterWindowsPlugin plugin;
  EncodableValue result_value;

  plugin.HandleMethodCall(
      MethodCall("collectNativeContext", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&result_value](const EncodableValue* result) {
            result_value = *result;
          },
          nullptr, nullptr));

  ASSERT_TRUE(std::holds_alternative<EncodableMap>(result_value));
  const auto& response = std::get<EncodableMap>(result_value);
  const auto metadata_it = response.find(EncodableValue("metadata"));
  ASSERT_NE(metadata_it, response.end());
  ASSERT_TRUE(std::holds_alternative<EncodableMap>(metadata_it->second));

  const auto& metadata = std::get<EncodableMap>(metadata_it->second);
  const auto source_it = metadata.find(EncodableValue("source"));
  ASSERT_NE(source_it, metadata.end());
  EXPECT_EQ(std::get<std::string>(source_it->second), "windows_native");
}

TEST(AttriaxFlutterWindowsPlugin, CollectInstallReferrer) {
  AttriaxFlutterWindowsPlugin plugin;
  EncodableValue result_value;

  plugin.HandleMethodCall(
      MethodCall("collectInstallReferrer", std::make_unique<EncodableValue>()),
      std::make_unique<MethodResultFunctions<>>(
          [&result_value](const EncodableValue* result) {
            result_value = *result;
          },
          nullptr, nullptr));

  ASSERT_TRUE(std::holds_alternative<EncodableMap>(result_value));
  const auto& response = std::get<EncodableMap>(result_value);
  const auto metadata_it = response.find(EncodableValue("metadata"));
  ASSERT_NE(metadata_it, response.end());
  ASSERT_TRUE(std::holds_alternative<EncodableMap>(metadata_it->second));

  const auto& metadata = std::get<EncodableMap>(metadata_it->second);
  const auto status_it = metadata.find(EncodableValue("installReferrerStatus"));
  ASSERT_NE(status_it, metadata.end());
  EXPECT_EQ(std::get<std::string>(status_it->second), "unsupported_windows");
}


}  // namespace test
}  // namespace attriax_flutter_windows
