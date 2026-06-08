# lucent_openapi.model.CreateMedicineReminderDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**currentMedicineId** | **String** | Linked current medicine id. | [optional] 
**label** | **Object** | Reminder label. | [optional] 
**scheduledHour** | **num** | Scheduled local hour, 0-23. | 
**scheduledMinute** | **num** | Scheduled local minute, 0-59. | 
**daysOfWeek** | **List&lt;num&gt;** | Weekday numbers 0-6, where null means every day. | [optional] 
**isActive** | **bool** | Whether this reminder is active. | [optional] [default to true]
**note** | **Object** | User note. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


