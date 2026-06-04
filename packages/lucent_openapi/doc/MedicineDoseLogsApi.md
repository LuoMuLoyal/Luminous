# lucent_openapi.api.MedicineDoseLogsApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**medicineDoseLogsControllerCreateV1**](MedicineDoseLogsApi.md#medicinedoselogscontrollercreatev1) | **POST** /api/v1/me/medicine-dose-logs | Create a dose log
[**medicineDoseLogsControllerDeleteV1**](MedicineDoseLogsApi.md#medicinedoselogscontrollerdeletev1) | **DELETE** /api/v1/me/medicine-dose-logs/{id} | Soft-delete a dose log
[**medicineDoseLogsControllerListV1**](MedicineDoseLogsApi.md#medicinedoselogscontrollerlistv1) | **GET** /api/v1/me/medicine-dose-logs | List dose logs for a date
[**medicineDoseLogsControllerUpdateV1**](MedicineDoseLogsApi.md#medicinedoselogscontrollerupdatev1) | **PATCH** /api/v1/me/medicine-dose-logs/{id} | Update a dose log


# **medicineDoseLogsControllerCreateV1**
> DoseLogResponseDto medicineDoseLogsControllerCreateV1(createDoseLogDto)

Create a dose log

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineDoseLogsApi();
final CreateDoseLogDto createDoseLogDto = ; // CreateDoseLogDto | 

try {
    final response = api.medicineDoseLogsControllerCreateV1(createDoseLogDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicineDoseLogsApi->medicineDoseLogsControllerCreateV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createDoseLogDto** | [**CreateDoseLogDto**](CreateDoseLogDto.md)|  | 

### Return type

[**DoseLogResponseDto**](DoseLogResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **medicineDoseLogsControllerDeleteV1**
> medicineDoseLogsControllerDeleteV1(id)

Soft-delete a dose log

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineDoseLogsApi();
final String id = id_example; // String | 

try {
    api.medicineDoseLogsControllerDeleteV1(id);
} on DioException catch (e) {
    print('Exception when calling MedicineDoseLogsApi->medicineDoseLogsControllerDeleteV1: $e\n');
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

# **medicineDoseLogsControllerListV1**
> DoseLogListResponseDto medicineDoseLogsControllerListV1(date)

List dose logs for a date

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineDoseLogsApi();
final String date = 2026-06-04; // String | 

try {
    final response = api.medicineDoseLogsControllerListV1(date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicineDoseLogsApi->medicineDoseLogsControllerListV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **String**|  | 

### Return type

[**DoseLogListResponseDto**](DoseLogListResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **medicineDoseLogsControllerUpdateV1**
> DoseLogResponseDto medicineDoseLogsControllerUpdateV1(id, updateDoseLogDto)

Update a dose log

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicineDoseLogsApi();
final String id = id_example; // String | 
final UpdateDoseLogDto updateDoseLogDto = ; // UpdateDoseLogDto | 

try {
    final response = api.medicineDoseLogsControllerUpdateV1(id, updateDoseLogDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicineDoseLogsApi->medicineDoseLogsControllerUpdateV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **updateDoseLogDto** | [**UpdateDoseLogDto**](UpdateDoseLogDto.md)|  | 

### Return type

[**DoseLogResponseDto**](DoseLogResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

