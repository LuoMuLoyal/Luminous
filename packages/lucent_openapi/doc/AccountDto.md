# lucent_openapi.model.AccountDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | User ID. | 
**email** | **Object** | Account email. OAuth-only accounts may not have one. | 
**nickname** | **Object** | Display nickname. | 
**avatar** | **Object** | Avatar URL. | 
**emailVerifiedAt** | **Object** | Account email verification time in ISO 8601. | 
**hasPassword** | **bool** | Whether the account has a local password. | 
**lastLoginAt** | **Object** | Last login time in ISO 8601. | 
**linkedIdentities** | [**List&lt;AccountIdentityDto&gt;**](AccountIdentityDto.md) | Linked third-party identities without provider user ids. | 
**createdAt** | **String** | Created time in ISO 8601. | 
**updatedAt** | **String** | Updated time in ISO 8601. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


