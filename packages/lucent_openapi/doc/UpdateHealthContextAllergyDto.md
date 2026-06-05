# lucent_openapi.model.UpdateHealthContextAllergyDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | [**UserAllergyKind**](UserAllergyKind.md) | Allergy kind. | [optional]
**label** | **String** | User-visible allergy label. | [optional]
**reaction** | **Object** | Recorded reaction. Use null to clear. | [optional]
**severity** | [**UserAllergySeverity**](UserAllergySeverity.md) | Severity level. | [optional]
**note** | **Object** | User note for the allergy. Use null to clear. | [optional]
**recordedAt** | **Object** | When this allergy was recorded in ISO 8601 format. | [optional]
**isActive** | **bool** | Whether the allergy is currently active. | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
