# lucent_openapi.model.UpdateMedicineReminderDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**currentMedicineId** | **Object** | Linked current medicine id. | [optional] 
**label** | **Object** | Reminder label. | [optional] 
**scheduledHour** | **num** | Scheduled local hour, 0-23. | [optional] 
**scheduledMinute** | **num** | Scheduled local minute, 0-59. | [optional] 
**daysOfWeek** | **List&lt;num&gt;** | Weekday numbers 0-6, where null means every day. | [optional] 
**startDate** | **Object** | Date in YYYY-MM-DD format when the reminder starts. Use null to clear. | [optional]
**endDate** | **Object** | Date in YYYY-MM-DD format when the reminder ends. Use null to clear. | [optional]
**isActive** | **bool** | Whether this reminder is active. | [optional] 
**note** | **Object** | User note. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)

