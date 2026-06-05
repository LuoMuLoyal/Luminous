# lucent_openapi.api.UserHealthContextApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**userHealthContextControllerCreateAllergyV1**](UserHealthContextApi.md#userhealthcontextcontrollercreateallergyv1) | **POST** /api/v1/me/health-context/allergies | Create an allergy record
[**userHealthContextControllerCreateConditionV1**](UserHealthContextApi.md#userhealthcontextcontrollercreateconditionv1) | **POST** /api/v1/me/health-context/conditions | Create a condition record
[**userHealthContextControllerCreateCurrentMedicineV1**](UserHealthContextApi.md#userhealthcontextcontrollercreatecurrentmedicinev1) | **POST** /api/v1/me/health-context/current-medicines | Add a current medicine record
[**userHealthContextControllerDeleteAllergyV1**](UserHealthContextApi.md#userhealthcontextcontrollerdeleteallergyv1) | **DELETE** /api/v1/me/health-context/allergies/{id} | Deactivate an allergy record (soft delete)
[**userHealthContextControllerDeleteConditionV1**](UserHealthContextApi.md#userhealthcontextcontrollerdeleteconditionv1) | **DELETE** /api/v1/me/health-context/conditions/{id} | Resolve a condition record (soft delete)
[**userHealthContextControllerDeleteCurrentMedicineV1**](UserHealthContextApi.md#userhealthcontextcontrollerdeletecurrentmedicinev1) | **DELETE** /api/v1/me/health-context/current-medicines/{id} | Deactivate a current medicine record (soft delete)
[**userHealthContextControllerGetMeHealthContextV1**](UserHealthContextApi.md#userhealthcontextcontrollergetmehealthcontextv1) | **GET** /api/v1/me/health-context | Get the current user health context aggregate
[**userHealthContextControllerUpdateAllergyV1**](UserHealthContextApi.md#userhealthcontextcontrollerupdateallergyv1) | **PATCH** /api/v1/me/health-context/allergies/{id} | Update an allergy record
[**userHealthContextControllerUpdateConditionV1**](UserHealthContextApi.md#userhealthcontextcontrollerupdateconditionv1) | **PATCH** /api/v1/me/health-context/conditions/{id} | Update a condition record
[**userHealthContextControllerUpdateCurrentMedicineV1**](UserHealthContextApi.md#userhealthcontextcontrollerupdatecurrentmedicinev1) | **PATCH** /api/v1/me/health-context/current-medicines/{id} | Update a current medicine record
[**userHealthContextControllerUpdateMeHealthContextProfileV1**](UserHealthContextApi.md#userhealthcontextcontrollerupdatemehealthcontextprofilev1) | **PATCH** /api/v1/me/health-context/profile | Update the current user health-context profile


# **userHealthContextControllerCreateAllergyV1**
> HealthContextResponseDto userHealthContextControllerCreateAllergyV1(createHealthContextAllergyDto)

Create an allergy record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final CreateHealthContextAllergyDto createHealthContextAllergyDto = ; // CreateHealthContextAllergyDto |

try {
    final response = api.userHealthContextControllerCreateAllergyV1(createHealthContextAllergyDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerCreateAllergyV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createHealthContextAllergyDto** | [**CreateHealthContextAllergyDto**](CreateHealthContextAllergyDto.md)|  |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerCreateConditionV1**
> HealthContextResponseDto userHealthContextControllerCreateConditionV1(createHealthContextConditionDto)

Create a condition record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final CreateHealthContextConditionDto createHealthContextConditionDto = ; // CreateHealthContextConditionDto |

try {
    final response = api.userHealthContextControllerCreateConditionV1(createHealthContextConditionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerCreateConditionV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createHealthContextConditionDto** | [**CreateHealthContextConditionDto**](CreateHealthContextConditionDto.md)|  |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerCreateCurrentMedicineV1**
> HealthContextResponseDto userHealthContextControllerCreateCurrentMedicineV1(createCurrentMedicineDto)

Add a current medicine record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final CreateCurrentMedicineDto createCurrentMedicineDto = ; // CreateCurrentMedicineDto |

try {
    final response = api.userHealthContextControllerCreateCurrentMedicineV1(createCurrentMedicineDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerCreateCurrentMedicineV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCurrentMedicineDto** | [**CreateCurrentMedicineDto**](CreateCurrentMedicineDto.md)|  |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerDeleteAllergyV1**
> HealthContextResponseDto userHealthContextControllerDeleteAllergyV1(id)

Deactivate an allergy record (soft delete)

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final String id = id_example; // String | Allergy id

try {
    final response = api.userHealthContextControllerDeleteAllergyV1(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerDeleteAllergyV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Allergy id |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerDeleteConditionV1**
> HealthContextResponseDto userHealthContextControllerDeleteConditionV1(id)

Resolve a condition record (soft delete)

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final String id = id_example; // String | Condition id

try {
    final response = api.userHealthContextControllerDeleteConditionV1(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerDeleteConditionV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Condition id |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerDeleteCurrentMedicineV1**
> HealthContextResponseDto userHealthContextControllerDeleteCurrentMedicineV1(id)

Deactivate a current medicine record (soft delete)

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final String id = id_example; // String | Current medicine id

try {
    final response = api.userHealthContextControllerDeleteCurrentMedicineV1(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerDeleteCurrentMedicineV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Current medicine id |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **userHealthContextControllerUpdateAllergyV1**
> HealthContextResponseDto userHealthContextControllerUpdateAllergyV1(id, updateHealthContextAllergyDto)

Update an allergy record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final String id = id_example; // String | Allergy id
final UpdateHealthContextAllergyDto updateHealthContextAllergyDto = ; // UpdateHealthContextAllergyDto |

try {
    final response = api.userHealthContextControllerUpdateAllergyV1(id, updateHealthContextAllergyDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerUpdateAllergyV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Allergy id |
 **updateHealthContextAllergyDto** | [**UpdateHealthContextAllergyDto**](UpdateHealthContextAllergyDto.md)|  |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerUpdateConditionV1**
> HealthContextResponseDto userHealthContextControllerUpdateConditionV1(id, updateHealthContextConditionDto)

Update a condition record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final String id = id_example; // String | Condition id
final UpdateHealthContextConditionDto updateHealthContextConditionDto = ; // UpdateHealthContextConditionDto |

try {
    final response = api.userHealthContextControllerUpdateConditionV1(id, updateHealthContextConditionDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerUpdateConditionV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Condition id |
 **updateHealthContextConditionDto** | [**UpdateHealthContextConditionDto**](UpdateHealthContextConditionDto.md)|  |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerUpdateCurrentMedicineV1**
> HealthContextResponseDto userHealthContextControllerUpdateCurrentMedicineV1(id, updateCurrentMedicineDto)

Update a current medicine record

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getUserHealthContextApi();
final String id = id_example; // String | Current medicine id
final UpdateCurrentMedicineDto updateCurrentMedicineDto = ; // UpdateCurrentMedicineDto |

try {
    final response = api.userHealthContextControllerUpdateCurrentMedicineV1(id, updateCurrentMedicineDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UserHealthContextApi->userHealthContextControllerUpdateCurrentMedicineV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**| Current medicine id |
 **updateCurrentMedicineDto** | [**UpdateCurrentMedicineDto**](UpdateCurrentMedicineDto.md)|  |

### Return type

[**HealthContextResponseDto**](HealthContextResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userHealthContextControllerUpdateMeHealthContextProfileV1**
> HealthContextResponseDto userHealthContextControllerUpdateMeHealthContextProfileV1(updateHealthContextProfileDto)

Update the current user health-context profile

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
