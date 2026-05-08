# attriax_api_client.api.SdkApi

## Load the API package
```dart
import 'package:attriax_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**sdkControllerBatchV1**](SdkApi.md#sdkcontrollerbatchv1) | **POST** /api/sdk/v1/batch | 
[**sdkControllerCreateDynamicLinkV1**](SdkApi.md#sdkcontrollercreatedynamiclinkv1) | **POST** /api/sdk/v1/dynamic-links | 
[**sdkControllerOpenV1**](SdkApi.md#sdkcontrolleropenv1) | **POST** /api/sdk/v1/open | 
[**sdkControllerRecordCrashV1**](SdkApi.md#sdkcontrollerrecordcrashv1) | **POST** /api/sdk/v1/crashes | 
[**sdkControllerRecordEventV1**](SdkApi.md#sdkcontrollerrecordeventv1) | **POST** /api/sdk/v1/events | 
[**sdkControllerRecordSessionV1**](SdkApi.md#sdkcontrollerrecordsessionv1) | **POST** /api/sdk/v1/sessions | 
[**sdkControllerRegisterUninstallTokenV1**](SdkApi.md#sdkcontrollerregisteruninstalltokenv1) | **POST** /api/sdk/v1/uninstall-tokens | 
[**sdkControllerResolveDeepLinkV1**](SdkApi.md#sdkcontrollerresolvedeeplinkv1) | **POST** /api/sdk/v1/deep-links/resolve | 
[**sdkControllerSetUserV1**](SdkApi.md#sdkcontrollersetuserv1) | **POST** /api/sdk/v1/users | 
[**sdkControllerValidateReceiptV1**](SdkApi.md#sdkcontrollervalidatereceiptv1) | **POST** /api/sdk/v1/revenue/receipts/validate | 


# **sdkControllerBatchV1**
> SdkV1BatchResponseEnvelopeDto sdkControllerBatchV1(sdkV1BatchDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkV1BatchDto sdkV1BatchDto = ; // SdkV1BatchDto | 

try {
    final response = api.sdkControllerBatchV1(sdkV1BatchDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerBatchV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkV1BatchDto** | [**SdkV1BatchDto**](SdkV1BatchDto.md)|  | 

### Return type

[**SdkV1BatchResponseEnvelopeDto**](SdkV1BatchResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerCreateDynamicLinkV1**
> SdkCreateDynamicLinkResponseEnvelopeDto sdkControllerCreateDynamicLinkV1(sdkCreateDynamicLinkDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkCreateDynamicLinkDto sdkCreateDynamicLinkDto = ; // SdkCreateDynamicLinkDto | 

try {
    final response = api.sdkControllerCreateDynamicLinkV1(sdkCreateDynamicLinkDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerCreateDynamicLinkV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkCreateDynamicLinkDto** | [**SdkCreateDynamicLinkDto**](SdkCreateDynamicLinkDto.md)|  | 

### Return type

[**SdkCreateDynamicLinkResponseEnvelopeDto**](SdkCreateDynamicLinkResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerOpenV1**
> SdkV1OpenResponseEnvelopeDto sdkControllerOpenV1(sdkV1OpenDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkV1OpenDto sdkV1OpenDto = ; // SdkV1OpenDto | 

try {
    final response = api.sdkControllerOpenV1(sdkV1OpenDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerOpenV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkV1OpenDto** | [**SdkV1OpenDto**](SdkV1OpenDto.md)|  | 

### Return type

[**SdkV1OpenResponseEnvelopeDto**](SdkV1OpenResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerRecordCrashV1**
> SdkAcknowledgeResponseEnvelopeDto sdkControllerRecordCrashV1(sdkCrashDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkCrashDto sdkCrashDto = ; // SdkCrashDto | 

try {
    final response = api.sdkControllerRecordCrashV1(sdkCrashDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerRecordCrashV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkCrashDto** | [**SdkCrashDto**](SdkCrashDto.md)|  | 

### Return type

[**SdkAcknowledgeResponseEnvelopeDto**](SdkAcknowledgeResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerRecordEventV1**
> SdkAcknowledgeResponseEnvelopeDto sdkControllerRecordEventV1(sdkEventDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkEventDto sdkEventDto = ; // SdkEventDto | 

try {
    final response = api.sdkControllerRecordEventV1(sdkEventDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerRecordEventV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkEventDto** | [**SdkEventDto**](SdkEventDto.md)|  | 

### Return type

[**SdkAcknowledgeResponseEnvelopeDto**](SdkAcknowledgeResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerRecordSessionV1**
> SdkAcknowledgeResponseEnvelopeDto sdkControllerRecordSessionV1(sdkSessionDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkSessionDto sdkSessionDto = ; // SdkSessionDto | 

try {
    final response = api.sdkControllerRecordSessionV1(sdkSessionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerRecordSessionV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkSessionDto** | [**SdkSessionDto**](SdkSessionDto.md)|  | 

### Return type

[**SdkAcknowledgeResponseEnvelopeDto**](SdkAcknowledgeResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerRegisterUninstallTokenV1**
> SdkAcknowledgeResponseEnvelopeDto sdkControllerRegisterUninstallTokenV1(sdkRegisterUninstallTokenDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkRegisterUninstallTokenDto sdkRegisterUninstallTokenDto = ; // SdkRegisterUninstallTokenDto | 

try {
    final response = api.sdkControllerRegisterUninstallTokenV1(sdkRegisterUninstallTokenDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerRegisterUninstallTokenV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkRegisterUninstallTokenDto** | [**SdkRegisterUninstallTokenDto**](SdkRegisterUninstallTokenDto.md)|  | 

### Return type

[**SdkAcknowledgeResponseEnvelopeDto**](SdkAcknowledgeResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerResolveDeepLinkV1**
> SdkV1DeepLinkResolveResponseEnvelopeDto sdkControllerResolveDeepLinkV1(sdkV1DeepLinkResolveDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkV1DeepLinkResolveDto sdkV1DeepLinkResolveDto = ; // SdkV1DeepLinkResolveDto | 

try {
    final response = api.sdkControllerResolveDeepLinkV1(sdkV1DeepLinkResolveDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerResolveDeepLinkV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkV1DeepLinkResolveDto** | [**SdkV1DeepLinkResolveDto**](SdkV1DeepLinkResolveDto.md)|  | 

### Return type

[**SdkV1DeepLinkResolveResponseEnvelopeDto**](SdkV1DeepLinkResolveResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerSetUserV1**
> SdkAcknowledgeResponseEnvelopeDto sdkControllerSetUserV1(sdkUserDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkUserDto sdkUserDto = ; // SdkUserDto | 

try {
    final response = api.sdkControllerSetUserV1(sdkUserDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerSetUserV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkUserDto** | [**SdkUserDto**](SdkUserDto.md)|  | 

### Return type

[**SdkAcknowledgeResponseEnvelopeDto**](SdkAcknowledgeResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sdkControllerValidateReceiptV1**
> SdkRevenueReceiptValidateResponseEnvelopeDto sdkControllerValidateReceiptV1(sdkV1RevenueReceiptValidateDto)



### Example
```dart
import 'package:attriax_api_client/api.dart';

final api = AttriaxSdkClient().getSdkApi();
final SdkV1RevenueReceiptValidateDto sdkV1RevenueReceiptValidateDto = ; // SdkV1RevenueReceiptValidateDto | 

try {
    final response = api.sdkControllerValidateReceiptV1(sdkV1RevenueReceiptValidateDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SdkApi->sdkControllerValidateReceiptV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sdkV1RevenueReceiptValidateDto** | [**SdkV1RevenueReceiptValidateDto**](SdkV1RevenueReceiptValidateDto.md)|  | 

### Return type

[**SdkRevenueReceiptValidateResponseEnvelopeDto**](SdkRevenueReceiptValidateResponseEnvelopeDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

