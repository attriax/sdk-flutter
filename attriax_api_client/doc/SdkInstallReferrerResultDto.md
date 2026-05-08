# attriax_api_client.model.SdkInstallReferrerResultDto

## Load the model package
```dart
import 'package:attriax_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**adClickId** | **String** | Detected ad click identifier such as gclid or fbclid. | [optional] 
**adNetwork** | **String** | Detected ad-network identifier inferred from the referrer. | [optional] 
**attributionType** | [**AttributionType**](AttributionType.md) | Attribution source classification for the install-referrer payload. Current platform install-referrer parsing reports `referrer`; `external` is reserved for future provider-based payloads. | 
**campaign** | **String** | Resolved UTM campaign extracted from the install referrer. | [optional] 
**content** | **String** | Resolved UTM content extracted from the install referrer. | [optional] 
**deepLinkData** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Resolved deep-link payload data associated with the install referrer. | [optional] 
**deepLinkUrl** | **String** | Full tracked short-link URL associated with the resolved deep link. | [optional] 
**medium** | **String** | Resolved UTM medium extracted from the install referrer. | [optional] 
**precision** | **num** | Confidence score from 0.0 to 1.0 for the returned interpretation. | 
**rawPlatformInstallReferrer** | **String** | Raw platform install-referrer string cached by the SDK. | [optional] 
**source_** | **String** | Resolved UTM source extracted from the install referrer. | [optional] 
**term** | **String** | Resolved UTM term extracted from the install referrer. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


