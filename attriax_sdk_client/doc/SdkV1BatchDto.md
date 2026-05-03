# attriax_sdk_client.model.SdkV1BatchDto

## Load the model package
```dart
import 'package:attriax_sdk_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appToken** | **String** | Shared app token for every item in the batch. | 
**deviceId** | **String** | Shared device identifier for every item in the batch. | 
**deviceIdSource** | **String** | Optional shared device-id source for every item in the batch. | [optional] 
**items** | [**BuiltList&lt;SdkV1BatchItemDto&gt;**](SdkV1BatchItemDto.md) |  | 
**requestId** | **String** | Stable client-generated batch identifier used for idempotent retries. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


