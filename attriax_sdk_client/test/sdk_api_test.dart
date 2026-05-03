import 'package:test/test.dart';
import 'package:attriax_sdk_client/attriax_sdk_client.dart';


/// tests for SdkApi
void main() {
  final instance = AttriaxSdkClient().getSdkApi();

  group(SdkApi, () {
    //Future<SdkV1BatchResponseEnvelopeDto> sdkControllerBatchV1(SdkV1BatchDto sdkV1BatchDto) async
    test('test sdkControllerBatchV1', () async {
      // TODO
    });

    //Future<SdkCreateDynamicLinkResponseEnvelopeDto> sdkControllerCreateDynamicLinkV1(SdkCreateDynamicLinkDto sdkCreateDynamicLinkDto) async
    test('test sdkControllerCreateDynamicLinkV1', () async {
      // TODO
    });

    //Future<SdkLatestUnityReleaseResponseEnvelopeDto> sdkControllerGetLatestUnityReleaseV1() async
    test('test sdkControllerGetLatestUnityReleaseV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerIdentifyV1(SdkIdentifyDto sdkIdentifyDto) async
    test('test sdkControllerIdentifyV1', () async {
      // TODO
    });

    //Future<SdkUnityReleaseListResponseEnvelopeDto> sdkControllerListUnityReleasesV1() async
    test('test sdkControllerListUnityReleasesV1', () async {
      // TODO
    });

    //Future<SdkV1OpenResponseEnvelopeDto> sdkControllerOpenV1(SdkV1OpenDto sdkV1OpenDto) async
    test('test sdkControllerOpenV1', () async {
      // TODO
    });

    //Future<SdkV1DeepLinkResolveResponseEnvelopeDto> sdkControllerResolveDeepLinkV1(SdkV1DeepLinkResolveDto sdkV1DeepLinkResolveDto) async
    test('test sdkControllerResolveDeepLinkV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerTrackEventV1(SdkEventDto sdkEventDto) async
    test('test sdkControllerTrackEventV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerTrackSessionV1(SdkSessionDto sdkSessionDto) async
    test('test sdkControllerTrackSessionV1', () async {
      // TODO
    });

    //Future<SdkUnityEditorValidateResponseEnvelopeDto> sdkControllerValidateUnityEditorV1(SdkV1UnityEditorValidateDto sdkV1UnityEditorValidateDto) async
    test('test sdkControllerValidateUnityEditorV1', () async {
      // TODO
    });

  });
}
