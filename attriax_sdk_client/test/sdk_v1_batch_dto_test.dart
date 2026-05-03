import 'package:test/test.dart';
import 'package:attriax_sdk_client/attriax_sdk_client.dart';

// tests for SdkV1BatchDto
void main() {
  final instance = SdkV1BatchDtoBuilder();
  // TODO add properties to the builder and call build()

  group(SdkV1BatchDto, () {
    // Shared app token for every item in the batch.
    // String appToken
    test('to test the property `appToken`', () async {
      // TODO
    });

    // Shared device identifier for every item in the batch.
    // String deviceId
    test('to test the property `deviceId`', () async {
      // TODO
    });

    // Optional shared device-id source for every item in the batch.
    // String deviceIdSource
    test('to test the property `deviceIdSource`', () async {
      // TODO
    });

    // BuiltList<SdkV1BatchItemDto> items
    test('to test the property `items`', () async {
      // TODO
    });

    // Stable client-generated batch identifier used for idempotent retries.
    // String requestId
    test('to test the property `requestId`', () async {
      // TODO
    });

  });
}
