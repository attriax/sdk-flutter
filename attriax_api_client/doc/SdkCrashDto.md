# attriax_api_client.model.SdkCrashDto

## Load the model package
```dart
import 'package:attriax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appBuildNumber** | **String** |  | [optional] 
**appPackageName** | **String** |  | [optional] 
**appToken** | **String** |  | 
**appVersion** | **String** |  | [optional] 
**clientOccurredAt** | [**DateTime**](DateTime.md) |  | 
**deviceId** | **String** |  | 
**deviceIdSource** | **String** |  | 
**exceptionType** | **String** |  | 
**isFatal** | **bool** |  | 
**isFirstLaunch** | **bool** |  | 
**locale** | **String** |  | [optional] 
**message** | **String** |  | 
**metadata** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 
**platform** | [**Platform**](Platform.md) |  | 
**reason** | **String** |  | [optional] 
**sdkApiVersion** | **String** |  | [optional] 
**sdkPackageVersion** | **String** |  | [optional] 
**sessionId** | **String** |  | [optional] 
**sessionRelativeTimeMs** | **num** | Milliseconds since the session started. | [optional] 
**source_** | **String** | Crash origin inside the SDK or native bridge. | 
**stackTrace** | **String** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


