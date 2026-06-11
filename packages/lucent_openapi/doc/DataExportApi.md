# lucent_openapi.api.DataExportApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**dataExportControllerCreateRequestV1**](DataExportApi.md#dataexportcontrollercreaterequestv1) | **POST** /api/v1/user/data-export-requests | Create a new data export request
[**dataExportControllerGetLatestRequestV1**](DataExportApi.md#dataexportcontrollergetlatestrequestv1) | **GET** /api/v1/user/data-export-requests/latest | Get the latest data export request


# **dataExportControllerCreateRequestV1**
> DataExportRequestResponseDto dataExportControllerCreateRequestV1()

Create a new data export request

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDataExportApi();

try {
    final response = api.dataExportControllerCreateRequestV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DataExportApi->dataExportControllerCreateRequestV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DataExportRequestResponseDto**](DataExportRequestResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **dataExportControllerGetLatestRequestV1**
> DataExportLatestResponseDto dataExportControllerGetLatestRequestV1()

Get the latest data export request

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getDataExportApi();

try {
    final response = api.dataExportControllerGetLatestRequestV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DataExportApi->dataExportControllerGetLatestRequestV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DataExportLatestResponseDto**](DataExportLatestResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

