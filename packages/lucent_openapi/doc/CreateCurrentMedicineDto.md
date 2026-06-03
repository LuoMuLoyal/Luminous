# lucent_openapi.model.CreateCurrentMedicineDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**source_** | [**MedicineSource**](MedicineSource.md) | Upstream source used to anchor this medicine. | 
**sourceRefId** | **String** | Source-specific reference id. Required for drugbank and cn sources. | [optional] 
**displayName** | **String** | Display name shown to the user. | 
**strengthText** | **String** | Strength text. | [optional] 
**doseText** | **String** | Dose text. | [optional] 
**route** | **String** | Administration route. | [optional] 
**startedAt** | **Object** | Start date in YYYY-MM-DD format. | [optional] 
**endedAt** | **Object** | End date in YYYY-MM-DD format. | [optional] 
**note** | **String** | User note for the medicine. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


