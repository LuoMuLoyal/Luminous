# lucent_openapi.model.UserConditionItemDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Condition id. |
**label** | **String** | Condition label. |
**status** | [**UserConditionStatus**](UserConditionStatus.md) | Condition status. |
**diagnosedAt** | **Object** | Diagnosis date in YYYY-MM-DD format. |
**resolvedAt** | **Object** | Resolved date in YYYY-MM-DD format. |
**note** | **Object** | User note for the condition. |
**extras** | **Map&lt;String, Object&gt;** | Sparse condition extensions stored in jsonb. |
**createdAt** | **String** | Created time in ISO 8601 format. |
**updatedAt** | **String** | Updated time in ISO 8601 format. |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
