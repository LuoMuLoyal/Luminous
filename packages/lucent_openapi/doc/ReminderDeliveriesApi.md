# lucent_openapi.api.ReminderDeliveriesApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reminderDeliveriesControllerListV1**](ReminderDeliveriesApi.md#reminderdeliveriescontrollerlistv1) | **GET** /api/v1/user/reminder-deliveries | List reminder delivery audit logs


# **reminderDeliveriesControllerListV1**
> ReminderDeliveryListResponseDto reminderDeliveriesControllerListV1(date, limit)

List reminder delivery audit logs

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getReminderDeliveriesApi();
final String date = 2026-06-10; // String | Optional scheduled date filter in YYYY-MM-DD format.
final String limit = 20; // String | Maximum rows to return. Clamped to 1-100.

try {
    final response = api.reminderDeliveriesControllerListV1(date, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReminderDeliveriesApi->reminderDeliveriesControllerListV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **String**| Optional scheduled date filter in YYYY-MM-DD format. | [optional] 
 **limit** | **String**| Maximum rows to return. Clamped to 1-100. | [optional] 

### Return type

[**ReminderDeliveryListResponseDto**](ReminderDeliveryListResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

