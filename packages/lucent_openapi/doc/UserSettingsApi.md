# lucent_openapi.api.UserSettingsApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**userSettingsControllerGetSettingsV1**](UserSettingsApi.md#usersettingscontrollergetsettingsv1) | **GET** /api/v1/user/settings | Get authenticated user settings
[**userSettingsControllerUpdateSettingsV1**](UserSettingsApi.md#usersettingscontrollerupdatesettingsv1) | **PATCH** /api/v1/user/settings | Update authenticated user settings


# **userSettingsControllerGetSettingsV1**
> UserSettingsResponseDto userSettingsControllerGetSettingsV1()

Get authenticated user settings

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserSettingsApi();

try {
    final response = api.userSettingsControllerGetSettingsV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserSettingsApi->userSettingsControllerGetSettingsV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserSettingsResponseDto**](UserSettingsResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userSettingsControllerUpdateSettingsV1**
> UserSettingsResponseDto userSettingsControllerUpdateSettingsV1(updateUserSettingsDto)

Update authenticated user settings

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserSettingsApi();
final UpdateUserSettingsDto updateUserSettingsDto = ; // UpdateUserSettingsDto | 

try {
    final response = api.userSettingsControllerUpdateSettingsV1(updateUserSettingsDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserSettingsApi->userSettingsControllerUpdateSettingsV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateUserSettingsDto** | [**UpdateUserSettingsDto**](UpdateUserSettingsDto.md)|  | 

### Return type

[**UserSettingsResponseDto**](UserSettingsResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

