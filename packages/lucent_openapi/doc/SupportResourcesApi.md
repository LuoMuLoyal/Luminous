# lucent_openapi.api.SupportResourcesApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**supportResourcesControllerGetAppInfoV1**](SupportResourcesApi.md#supportresourcescontrollergetappinfov1) | **GET** /api/v1/public/app-info | Get application metadata
[**supportResourcesControllerGetResourcesV1**](SupportResourcesApi.md#supportresourcescontrollergetresourcesv1) | **GET** /api/v1/public/support-resources | Get static support resource entries


# **supportResourcesControllerGetAppInfoV1**
> AppInfoResponseDto supportResourcesControllerGetAppInfoV1()

Get application metadata

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getSupportResourcesApi();

try {
    final response = api.supportResourcesControllerGetAppInfoV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupportResourcesApi->supportResourcesControllerGetAppInfoV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AppInfoResponseDto**](AppInfoResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **supportResourcesControllerGetResourcesV1**
> SupportResourceListResponseDto supportResourcesControllerGetResourcesV1(scope)

Get static support resource entries

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getSupportResourcesApi();
final String scope = scope_example; // String | Filter by scope: 'campus', 'help', 'about'. Default: all.

try {
    final response = api.supportResourcesControllerGetResourcesV1(scope);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SupportResourcesApi->supportResourcesControllerGetResourcesV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **scope** | **String**| Filter by scope: 'campus', 'help', 'about'. Default: all. | [optional] 

### Return type

[**SupportResourceListResponseDto**](SupportResourceListResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

