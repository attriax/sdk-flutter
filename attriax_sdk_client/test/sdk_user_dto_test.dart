import 'package:test/test.dart';
import 'package:attriax_sdk_client/attriax_sdk_client.dart';

// tests for SdkUserDto
void main() {
  final instance = SdkUserDtoBuilder();
  // TODO add properties to the builder and call build()

  group(SdkUserDto, () {
    // String appToken
    test('to test the property `appToken`', () async {
      // TODO
    });

    // Clears every stored user property before applying this request.
    // bool clearAllProperties
    test('to test the property `clearAllProperties`', () async {
      // TODO
    });

    // Clears the stored external user id and name for future events.
    // bool clearExternalUser
    test('to test the property `clearExternalUser`', () async {
      // TODO
    });

    // Specific stored user-property keys to clear.
    // BuiltList<String> clearPropertyKeys
    test('to test the property `clearPropertyKeys`', () async {
      // TODO
    });

    // String deviceId
    test('to test the property `deviceId`', () async {
      // TODO
    });

    // String deviceIdSource
    test('to test the property `deviceIdSource`', () async {
      // TODO
    });

    // String externalUserId
    test('to test the property `externalUserId`', () async {
      // TODO
    });

    // String externalUserName
    test('to test the property `externalUserName`', () async {
      // TODO
    });

    // User properties merged into future event payloads until they are cleared or replaced.
    // BuiltMap<String, JsonObject> properties
    test('to test the property `properties`', () async {
      // TODO
    });

  });
}
