# lucent_openapi.model.DailyRecordImageUploadDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**provider** | **String** |  | 
**bucket** | **String** |  | 
**objectKey** | **String** |  | 
**uploadUrl** | **String** | Signed PUT URL for direct COS upload. | 
**headers** | **Object** | Headers that must be sent with the PUT upload. | 
**publicUrl** | **Object** | Optional public/CDN URL when TENCENT_COS_PUBLIC_BASE_URL is configured. | 
**expiresAt** | **String** | Signed URL expiry timestamp (ISO 8601). | 
**maxSizeBytes** | **num** | Maximum accepted upload size in bytes. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


