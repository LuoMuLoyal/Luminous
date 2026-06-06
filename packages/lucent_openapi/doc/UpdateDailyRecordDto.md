# lucent_openapi.model.UpdateDailyRecordDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | [**DailyRecordKind**](DailyRecordKind.md) |  | [optional] 
**occurredAt** | **String** | Date in YYYY-MM-DD format. | [optional] 
**title** | **Object** | Short label. Use null to clear. | [optional] 
**value** | **Object** | Measured value. Use null to clear. | [optional] 
**unit** | **Object** | Unit label. Use null to clear. | [optional] 
**note** | **Object** | Free-text note. Use null to clear. | [optional] 
**attachments** | [**List&lt;DailyRecordAttachmentInputDto&gt;**](DailyRecordAttachmentInputDto.md) | Replacement attachment metadata list. Omit to keep existing attachments; send [] to clear. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


