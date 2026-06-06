# lucent_openapi.model.DailyRecordAttachmentInputDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**kind** | [**DailyRecordAttachmentKind**](DailyRecordAttachmentKind.md) |  | [optional] [default to DailyRecordAttachmentKind.image]
**objectKey** | **String** | Object storage key, stable across signed URL rotations. | 
**bucket** | **Object** | Object storage bucket. | [optional] 
**provider** | **Object** | Storage provider, currently tencent-cos. | [optional] 
**fileName** | **Object** | Original file name. | [optional] 
**contentType** | **Object** | MIME content type. | [optional] 
**sizeBytes** | **Object** | File size in bytes. | [optional] 
**width** | **Object** | Image width in pixels. | [optional] 
**height** | **Object** | Image height in pixels. | [optional] 
**publicUrl** | **Object** | Optional public or already-signed display URL. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


