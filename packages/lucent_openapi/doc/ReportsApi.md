# lucent_openapi.api.ReportsApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**reportsControllerGetDashboardV1**](ReportsApi.md#reportscontrollergetdashboardv1) | **GET** /api/v1/user/reports/dashboard | Get authenticated user report dashboard


# **reportsControllerGetDashboardV1**
> ReportDashboardResponseDto reportsControllerGetDashboardV1(range)

Get authenticated user report dashboard

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getReportsApi();
final String range = range_example; // String | Supported report aggregation range.

try {
    final response = api.reportsControllerGetDashboardV1(range);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportsApi->reportsControllerGetDashboardV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **range** | **String**| Supported report aggregation range. | [optional] [default to 'last_7_days']

### Return type

[**ReportDashboardResponseDto**](ReportDashboardResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

