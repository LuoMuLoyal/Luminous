# lucent_openapi.api.EnvironmentApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**environmentControllerGetSnapshotV1**](EnvironmentApi.md#environmentcontrollergetsnapshotv1) | **GET** /api/v1/environment/snapshot | Get static environment snapshot reference data


# **environmentControllerGetSnapshotV1**
> EnvironmentSnapshotResponseDto environmentControllerGetSnapshotV1(lat, lon)

Get static environment snapshot reference data

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getEnvironmentApi();
final num lat = 31.2304; // num | Approximate latitude.
final num lon = 121.4737; // num | Approximate longitude.

try {
    final response = api.environmentControllerGetSnapshotV1(lat, lon);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EnvironmentApi->environmentControllerGetSnapshotV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **num**| Approximate latitude. | [optional] 
 **lon** | **num**| Approximate longitude. | [optional] 

### Return type

[**EnvironmentSnapshotResponseDto**](EnvironmentSnapshotResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

