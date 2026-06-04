# lucent_openapi.api.DailyRecordsApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**dailyRecordsControllerCreateV1**](DailyRecordsApi.md#dailyrecordscontrollercreatev1) | **POST** /api/v1/me/daily-records | Create a daily record
[**dailyRecordsControllerDeleteV1**](DailyRecordsApi.md#dailyrecordscontrollerdeletev1) | **DELETE** /api/v1/me/daily-records/{id} | Soft-delete a daily record
[**dailyRecordsControllerListV1**](DailyRecordsApi.md#dailyrecordscontrollerlistv1) | **GET** /api/v1/me/daily-records | List daily records for a given date
[**dailyRecordsControllerSummaryV1**](DailyRecordsApi.md#dailyrecordscontrollersummaryv1) | **GET** /api/v1/me/daily-records/summary | Get daily record summary (counts by kind)
[**dailyRecordsControllerUpdateV1**](DailyRecordsApi.md#dailyrecordscontrollerupdatev1) | **PATCH** /api/v1/me/daily-records/{id} | Update a daily record


# **dailyRecordsControllerCreateV1**
> DailyRecordResponseDto dailyRecordsControllerCreateV1(createDailyRecordDto)

Create a daily record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDailyRecordsApi();
final CreateDailyRecordDto createDailyRecordDto = ; // CreateDailyRecordDto | 

try {
    final response = api.dailyRecordsControllerCreateV1(createDailyRecordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DailyRecordsApi->dailyRecordsControllerCreateV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createDailyRecordDto** | [**CreateDailyRecordDto**](CreateDailyRecordDto.md)|  | 

### Return type

[**DailyRecordResponseDto**](DailyRecordResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dailyRecordsControllerDeleteV1**
> dailyRecordsControllerDeleteV1(id)

Soft-delete a daily record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDailyRecordsApi();
final String id = id_example; // String | 

try {
    api.dailyRecordsControllerDeleteV1(id);
} on DioException catch (e) {
    print('Exception when calling DailyRecordsApi->dailyRecordsControllerDeleteV1: $e\n');
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

# **dailyRecordsControllerListV1**
> DailyRecordListResponseDto dailyRecordsControllerListV1(date, kind, page, pageSize)

List daily records for a given date

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDailyRecordsApi();
final String date = 2026-06-04; // String | 
final String kind = kind_example; // String | 
final String page = page_example; // String | 
final String pageSize = pageSize_example; // String | 

try {
    final response = api.dailyRecordsControllerListV1(date, kind, page, pageSize);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DailyRecordsApi->dailyRecordsControllerListV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **String**|  | 
 **kind** | **String**|  | [optional] 
 **page** | **String**|  | [optional] 
 **pageSize** | **String**|  | [optional] 

### Return type

[**DailyRecordListResponseDto**](DailyRecordListResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dailyRecordsControllerSummaryV1**
> DailyRecordSummaryResponseDto dailyRecordsControllerSummaryV1(date)

Get daily record summary (counts by kind)

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDailyRecordsApi();
final String date = 2026-06-04; // String | 

try {
    final response = api.dailyRecordsControllerSummaryV1(date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DailyRecordsApi->dailyRecordsControllerSummaryV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **String**|  | 

### Return type

[**DailyRecordSummaryResponseDto**](DailyRecordSummaryResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dailyRecordsControllerUpdateV1**
> DailyRecordResponseDto dailyRecordsControllerUpdateV1(id, updateDailyRecordDto)

Update a daily record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDailyRecordsApi();
final String id = id_example; // String | 
final UpdateDailyRecordDto updateDailyRecordDto = ; // UpdateDailyRecordDto | 

try {
    final response = api.dailyRecordsControllerUpdateV1(id, updateDailyRecordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DailyRecordsApi->dailyRecordsControllerUpdateV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateDailyRecordDto** | [**UpdateDailyRecordDto**](UpdateDailyRecordDto.md)|  | 

### Return type

[**DailyRecordResponseDto**](DailyRecordResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

