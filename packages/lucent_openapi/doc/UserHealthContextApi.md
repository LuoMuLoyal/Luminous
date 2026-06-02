# lucent_openapi.api.UserHealthContextApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**userHealthContextControllerGetMeHealthContextV1**](UserHealthContextApi.md#userhealthcontextcontrollergetmehealthcontextv1) | **GET** /api/v1/me/health-context | Get the current user health context aggregate
[**userHealthContextControllerUpdateMeHealthContextProfileV1**](UserHealthContextApi.md#userhealthcontextcontrollerupdatemehealthcontextprofilev1) | **PATCH** /api/v1/me/health-context/profile | Update the current user health-context profile preferences


# **userHealthContextControllerGetMeHealthContextV1**
> HealthContextResponseDto userHealthContextControllerGetMeHealthContextV1()

Get the current user health context aggregate

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();

try {
    final response = api.userHealthContextControllerGetMeHealthContextV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerGetMeHealthContextV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerUpdateMeHealthContextProfileV1**
> HealthContextResponseDto userHealthContextControllerUpdateMeHealthContextProfileV1(updateHealthContextProfileDto)

Update the current user health-context profile preferences

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final UpdateHealthContextProfileDto updateHealthContextProfileDto = ; // UpdateHealthContextProfileDto | 

try {
    final response = api.userHealthContextControllerUpdateMeHealthContextProfileV1(updateHealthContextProfileDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerUpdateMeHealthContextProfileV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateHealthContextProfileDto** | [**UpdateHealthContextProfileDto**](UpdateHealthContextProfileDto.md)|  | 

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

