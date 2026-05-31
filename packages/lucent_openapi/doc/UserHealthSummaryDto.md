# lucent_openapi.model.UserHealthSummaryDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**age** | **Object** | Age derived from birth date. Null when birth date is missing. | 
**onboardingCompleted** | **bool** | Whether the onboarding flow has been completed. | 
**activeAllergyCount** | **num** | Number of active allergy records returned in this payload. | 
**conditionCount** | **num** | Number of condition records returned in this payload. | 
**currentMedicineCount** | **num** | Number of current medicine records returned in this payload. | 
**missingCoreProfileFields** | **List&lt;String&gt;** | Missing core profile fields that the frontend can use for onboarding nudges. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


