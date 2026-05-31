# lucent_openapi.model.UserCurrentMedicineItemDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Current medicine id. | 
**source_** | [**MedicineSource**](MedicineSource.md) | Upstream source used to anchor this medicine. | 
**sourceRefId** | **Object** | Source-specific reference id. | 
**displayName** | **String** | Display name shown to the user. | 
**strengthText** | **Object** | Strength text. | 
**doseText** | **Object** | Dose text. | 
**route** | **Object** | Administration route. | 
**startedAt** | **Object** | Start date in YYYY-MM-DD format. | 
**endedAt** | **Object** | End date in YYYY-MM-DD format. | 
**isCurrent** | **bool** | Whether the medicine is currently active. | 
**note** | **Object** | User note for the medicine. | 
**sourcePayload** | **Map&lt;String, Object&gt;** | Original source payload stored in jsonb. | 
**createdAt** | **String** | Created time in ISO 8601 format. | 
**updatedAt** | **String** | Updated time in ISO 8601 format. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


