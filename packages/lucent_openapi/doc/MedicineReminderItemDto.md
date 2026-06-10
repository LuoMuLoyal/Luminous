# lucent_openapi.model.MedicineReminderItemDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Reminder id. | 
**currentMedicineId** | **Object** | Linked current medicine id. | [optional] 
**label** | **Object** | Reminder label. | [optional] 
**scheduledHour** | **num** | Scheduled local hour, 0-23. | 
**scheduledMinute** | **num** | Scheduled local minute, 0-59. | 
**daysOfWeek** | **List&lt;num&gt;** | Weekday numbers 0-6. Null means every day. | [optional] 
**startDate** | **Object** | Date in YYYY-MM-DD format when the reminder starts. | [optional]
**endDate** | **Object** | Date in YYYY-MM-DD format when the reminder ends. | [optional]
**isActive** | **bool** | Whether this reminder is active. | 
**note** | **Object** | User note. | [optional] 
**createdAt** | **String** | Created at (ISO 8601). | 
**updatedAt** | **String** | Updated at (ISO 8601). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)

