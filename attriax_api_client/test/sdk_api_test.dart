import 'package:test/test.dart';
import 'package:attriax_api_client/attriax_api_client.dart';

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

    //Future<SdkV1OpenResponseEnvelopeDto> sdkControllerOpenV1(SdkV1OpenDto sdkV1OpenDto) async
    test('test sdkControllerOpenV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerRecordCrashV1(SdkCrashDto sdkCrashDto) async
    test('test sdkControllerRecordCrashV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerRecordEventV1(SdkEventDto sdkEventDto) async
    test('test sdkControllerRecordEventV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerRecordSessionV1(SdkSessionDto sdkSessionDto) async
    test('test sdkControllerRecordSessionV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerRegisterUninstallTokenV1(SdkRegisterUninstallTokenDto sdkRegisterUninstallTokenDto) async
    test('test sdkControllerRegisterUninstallTokenV1', () async {
      // TODO
    });

    //Future<SdkV1DeepLinkResolveResponseEnvelopeDto> sdkControllerResolveDeepLinkV1(SdkV1DeepLinkResolveDto sdkV1DeepLinkResolveDto) async
    test('test sdkControllerResolveDeepLinkV1', () async {
      // TODO
    });

    //Future<SdkAcknowledgeResponseEnvelopeDto> sdkControllerSetUserV1(SdkUserDto sdkUserDto) async
    test('test sdkControllerSetUserV1', () async {
      // TODO
    });

    //Future<SdkRevenueReceiptValidateResponseEnvelopeDto> sdkControllerValidateReceiptV1(SdkV1RevenueReceiptValidateDto sdkV1RevenueReceiptValidateDto) async
    test('test sdkControllerValidateReceiptV1', () async {
      // TODO
    });
  });
}
