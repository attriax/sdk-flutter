# attriax_api_client.model.SdkUserDto

## Load the model package
```dart
import 'package:attriax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appToken** | **String** |  | 
**clearAllProperties** | **bool** | Clears every stored user property before applying this request. | [optional] 
**clearExternalUser** | **bool** | Clears the stored external user id and name for future events. | [optional] 
**clearPropertyKeys** | **BuiltList&lt;String&gt;** | Specific stored user-property keys to clear. | [optional] 
**deviceId** | **String** |  | 
**deviceIdSource** | **String** |  | [optional] 
**externalUserId** | **String** |  | [optional] 
**externalUserName** | **String** |  | [optional] 
**properties** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | User properties merged into future event payloads until they are cleared or replaced. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


