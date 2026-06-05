# lucent_openapi.api.MedicinesApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**medicinesControllerGetDetailV1**](MedicinesApi.md#medicinescontrollergetdetailv1) | **GET** /api/v1/medicines/{id} | Get medicine detail from a selected knowledge source
[**medicinesControllerSearchV1**](MedicinesApi.md#medicinescontrollersearchv1) | **GET** /api/v1/medicines | Search medicines from a selected knowledge source


# **medicinesControllerGetDetailV1**
> MedicineDetailResponseDto medicinesControllerGetDetailV1(id, source_, xBypassCache)

Get medicine detail from a selected knowledge source

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicinesApi();
final String id = id_example; // String | Medicine id in the selected source
final String source_ = source__example; // String | Knowledge source selector.
final String xBypassCache = xBypassCache_example; // String | Set to true/1/no-cache to bypass medicines read cache for this request only.

try {
    final response = api.medicinesControllerGetDetailV1(id, source_, xBypassCache);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicinesApi->medicinesControllerGetDetailV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Medicine id in the selected source |
 **source_** | **String**| Knowledge source selector. | [optional] [default to 'drugbank']
 **xBypassCache** | **String**| Set to true/1/no-cache to bypass medicines read cache for this request only. | [optional]

### Return type

[**MedicineDetailResponseDto**](MedicineDetailResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **medicinesControllerSearchV1**
> MedicineSearchResponseDto medicinesControllerSearchV1(source_, q, page, pageSize, xBypassCache)

Search medicines from a selected knowledge source

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getMedicinesApi();
final String source_ = source__example; // String | Knowledge source selector.
final String q = ibuprofen; // String | Search keyword.
final Object page = 1; // Object | Page number, 1-based.
final Object pageSize = 20; // Object | Page size.
final String xBypassCache = xBypassCache_example; // String | Set to true/1/no-cache to bypass medicines read cache for this request only.

try {
    final response = api.medicinesControllerSearchV1(source_, q, page, pageSize, xBypassCache);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MedicinesApi->medicinesControllerSearchV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **source_** | **String**| Knowledge source selector. | [optional] [default to 'drugbank']
 **q** | **String**| Search keyword. | [optional]
 **page** | [**Object**](.md)| Page number, 1-based. | [optional] [default to 1]
 **pageSize** | [**Object**](.md)| Page size. | [optional] [default to 20]
 **xBypassCache** | **String**| Set to true/1/no-cache to bypass medicines read cache for this request only. | [optional]

### Return type

[**MedicineSearchResponseDto**](MedicineSearchResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
