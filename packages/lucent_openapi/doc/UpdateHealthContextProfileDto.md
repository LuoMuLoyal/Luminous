# lucent_openapi.model.UpdateHealthContextProfileDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**locale** | **Object** | Preferred locale. Use null or empty string to clear and follow the client default. | [optional] 
**timezone** | **Object** | Preferred timezone. Use null or empty string to clear. | [optional] 
**unitSystem** | [**UnitSystem**](UnitSystem.md) | Preferred unit system. Use null to clear. | [optional] 
**birthDate** | **Object** | Birth date in YYYY-MM-DD format. | [optional] 
**sexAtBirth** | [**SexAtBirth**](SexAtBirth.md) | Sex assigned at birth. Use null to clear. | [optional] 
**heightCm** | **Object** | Height in centimeters. Use null to clear. | [optional] 
**pregnancyState** | [**PregnancyState**](PregnancyState.md) | Pregnancy state for personalized medical guidance. Use null to clear. | [optional] 
**lactationState** | [**LactationState**](LactationState.md) | Lactation state for personalized medical guidance. Use null to clear. | [optional] 
**bloodType** | **Object** | Blood type. Use null to clear. | [optional] 
**onboardingCompleted** | **bool** | Set true to complete onboarding (sets completedAt when missing). Set false to clear onboarding completion. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


