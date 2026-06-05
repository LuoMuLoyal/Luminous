# lucent_openapi.model.CreateHealthContextAllergyDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | [**UserAllergyKind**](UserAllergyKind.md) | Allergy kind. | 
**label** | **String** | User-visible allergy label. | 
**reaction** | **String** | Recorded reaction. | [optional] 
**severity** | [**UserAllergySeverity**](UserAllergySeverity.md) | Severity level. Defaults to unknown. | [optional] 
**note** | **String** | User note for the allergy. | [optional] 
**recordedAt** | **String** | When this allergy was recorded in ISO 8601 format. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


