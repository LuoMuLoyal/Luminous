# lucent_openapi.model.UserAllergyItemDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Allergy id. | 
**kind** | [**UserAllergyKind**](UserAllergyKind.md) | Allergy kind. | 
**label** | **String** | User-visible allergy label. | 
**reaction** | **Object** | Recorded reaction. | 
**severity** | [**UserAllergySeverity**](UserAllergySeverity.md) | Severity level. | 
**isActive** | **bool** | Whether the allergy is currently active. | 
**note** | **Object** | User note for the allergy. | 
**extras** | **Map&lt;String, Object&gt;** | Sparse allergy extensions stored in jsonb. | 
**recordedAt** | **Object** | When this allergy was recorded. | 
**createdAt** | **String** | Created time in ISO 8601 format. | 
**updatedAt** | **String** | Updated time in ISO 8601 format. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


