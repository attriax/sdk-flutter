# attriax_sdk_client.model.SdkSessionDto

## Load the model package
```dart
import 'package:attriax_sdk_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appBuildNumber** | **String** |  | [optional] 
**appPackageName** | **String** |  | [optional] 
**appToken** | **String** |  | 
**appVersion** | **String** |  | [optional] 
**clientOccurredAt** | [**DateTime**](DateTime.md) |  | [optional] 
**deviceId** | **String** |  | 
**deviceIdSource** | **String** |  | [optional] 
**isFirstLaunch** | **bool** |  | [optional] 
**kind** | [**SdkSessionLifecycleKind**](SdkSessionLifecycleKind.md) |  | 
**locale** | **String** |  | [optional] 
**metadata** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**platform** | [**Platform**](Platform.md) |  | [optional] 
**sdkApiVersion** | **String** |  | [optional] 
**sdkPackageVersion** | **String** |  | [optional] 
**sessionId** | **String** |  | 
**sessionRelativeTimeMs** | **num** | Milliseconds since the session started. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


