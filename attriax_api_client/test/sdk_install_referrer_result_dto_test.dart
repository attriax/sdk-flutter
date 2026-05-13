import 'package:test/test.dart';
import 'package:attriax_api_client/attriax_api_client.dart';

// tests for SdkInstallReferrerResultDto
void main() {
  final instance = SdkInstallReferrerResultDtoBuilder();
  // TODO add properties to the builder and call build()

  group(SdkInstallReferrerResultDto, () {
    // Detected ad click identifier such as gclid or fbclid.
    // String adClickId
    test('to test the property `adClickId`', () async {
      // TODO
    });

    // Detected ad-network identifier inferred from the referrer.
    // String adNetwork
    test('to test the property `adNetwork`', () async {
      // TODO
    });

    // Attribution source classification for the startup referrer payload.
    // AttributionType attributionType
    test('to test the property `attributionType`', () async {
      // TODO
    });

    // Resolved UTM campaign extracted from the install referrer.
    // String campaign
    test('to test the property `campaign`', () async {
      // TODO
    });

    // Resolved UTM content extracted from the install referrer.
    // String content
    test('to test the property `content`', () async {
      // TODO
    });

    // Resolved deep-link payload data associated with the startup referrer.
    // BuiltMap<String, String> deepLinkData
    test('to test the property `deepLinkData`', () async {
      // TODO
    });

    // Full tracked short-link URI associated with the resolved deep link.
    // String deepLinkUri
    test('to test the property `deepLinkUri`', () async {
      // TODO
    });

    // Deprecated alias for deepLinkUri kept for HTTP compatibility.
    // String deepLinkUrl
    test('to test the property `deepLinkUrl`', () async {
      // TODO
    });

    // bool googlePlayInstantParam
    test('to test the property `googlePlayInstantParam`', () async {
      // TODO
    });

    // num installBeginTimestampSeconds
    test('to test the property `installBeginTimestampSeconds`', () async {
      // TODO
    });

    // Resolved UTM medium extracted from the install referrer.
    // String medium
    test('to test the property `medium`', () async {
      // TODO
    });

    // Confidence score from 0.0 to 1.0 for the returned interpretation.
    // num precision
    test('to test the property `precision`', () async {
      // TODO
    });

    // Raw platform startup referrer string cached by the SDK, when available.
    // String rawPlatformInstallReferrer
    test('to test the property `rawPlatformInstallReferrer`', () async {
      // TODO
    });

    // num referrerClickTimestampSeconds
    test('to test the property `referrerClickTimestampSeconds`', () async {
      // TODO
    });

    // DateTime registeredAt
    test('to test the property `registeredAt`', () async {
      // TODO
    });

    // Resolved UTM source extracted from the install referrer.
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // Resolved UTM term extracted from the install referrer.
    // String term
    test('to test the property `term`', () async {
      // TODO
    });
  });
}
