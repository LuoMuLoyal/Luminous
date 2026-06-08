# lucent_openapi.api.MedicineRemindersApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**medicineRemindersControllerCreateV1**](MedicineRemindersApi.md#medicinereminderscontrollercreatev1) | **POST** /api/v1/me/medicine-reminders | Create a medicine reminder schedule
[**medicineRemindersControllerDeleteV1**](MedicineRemindersApi.md#medicinereminderscontrollerdeletev1) | **DELETE** /api/v1/me/medicine-reminders/{id} | Soft-delete a medicine reminder schedule
[**medicineRemindersControllerListV1**](MedicineRemindersApi.md#medicinereminderscontrollerlistv1) | **GET** /api/v1/me/medicine-reminders | List medicine reminder schedules
[**medicineRemindersControllerUpdateV1**](MedicineRemindersApi.md#medicinereminderscontrollerupdatev1) | **PATCH** /api/v1/me/medicine-reminders/{id} | Update a medicine reminder schedule


# **medicineRemindersControllerCreateV1**
> MedicineReminderResponseDto medicineRemindersControllerCreateV1(createMedicineReminderDto)

Create a medicine reminder schedule

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineRemindersApi();
final CreateMedicineReminderDto createMedicineReminderDto = ; // CreateMedicineReminderDto | 

try {
    final response = api.medicineRemindersControllerCreateV1(createMedicineReminderDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicineRemindersApi->medicineRemindersControllerCreateV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createMedicineReminderDto** | [**CreateMedicineReminderDto**](CreateMedicineReminderDto.md)|  | 

### Return type

[**MedicineReminderResponseDto**](MedicineReminderResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **medicineRemindersControllerDeleteV1**
> medicineRemindersControllerDeleteV1(id)

Soft-delete a medicine reminder schedule

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineRemindersApi();
final String id = id_example; // String | 

try {
    api.medicineRemindersControllerDeleteV1(id);
} on DioException catch (e) {
    print('Exception when calling MedicineRemindersApi->medicineRemindersControllerDeleteV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **medicineRemindersControllerListV1**
> MedicineReminderListResponseDto medicineRemindersControllerListV1(activeOnly)

List medicine reminder schedules

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineRemindersApi();
final String activeOnly = activeOnly_example; // String | Set to true to return active reminders only.

try {
    final response = api.medicineRemindersControllerListV1(activeOnly);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicineRemindersApi->medicineRemindersControllerListV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activeOnly** | **String**| Set to true to return active reminders only. | [optional] 

### Return type

[**MedicineReminderListResponseDto**](MedicineReminderListResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **medicineRemindersControllerUpdateV1**
> MedicineReminderResponseDto medicineRemindersControllerUpdateV1(id, updateMedicineReminderDto)

Update a medicine reminder schedule

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineRemindersApi();
final String id = id_example; // String | 
final UpdateMedicineReminderDto updateMedicineReminderDto = ; // UpdateMedicineReminderDto | 

try {
    final response = api.medicineRemindersControllerUpdateV1(id, updateMedicineReminderDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicineRemindersApi->medicineRemindersControllerUpdateV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateMedicineReminderDto** | [**UpdateMedicineReminderDto**](UpdateMedicineReminderDto.md)|  | 

### Return type

[**MedicineReminderResponseDto**](MedicineReminderResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

