# lucent_openapi.model.ReminderDeliveryItemDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Delivery log id. | 
**reminderId** | **Object** | Linked medicine reminder id. | [optional] 
**deviceId** | **Object** | Target device id. | [optional] 
**channel** | **String** | Delivery channel. | 
**status** | **String** | Delivery status. | 
**scheduledFor** | **String** | Scheduled delivery time (ISO 8601). | 
**deliveredAt** | **Object** | Actual delivery time (ISO 8601). | [optional] 
**errorMessage** | **Object** | Failure reason, if any. | [optional] 
**createdAt** | **String** | Created at (ISO 8601). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


