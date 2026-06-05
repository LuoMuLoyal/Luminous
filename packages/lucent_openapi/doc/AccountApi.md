# lucent_openapi.api.AccountApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**accountControllerChangeEmailV1**](AccountApi.md#accountcontrollerchangeemailv1) | **POST** /api/v1/account/email | Change authenticated account email
[**accountControllerChangePasswordV1**](AccountApi.md#accountcontrollerchangepasswordv1) | **POST** /api/v1/account/password | Change authenticated account password
[**accountControllerDeleteAccountV1**](AccountApi.md#accountcontrollerdeleteaccountv1) | **DELETE** /api/v1/account | Delete authenticated account
[**accountControllerGetAccountV1**](AccountApi.md#accountcontrollergetaccountv1) | **GET** /api/v1/account | Get authenticated account profile
[**accountControllerUnlinkIdentityV1**](AccountApi.md#accountcontrollerunlinkidentityv1) | **DELETE** /api/v1/account/identities/{identityId} | Unlink authenticated account OAuth identity
[**accountControllerUpdateAccountV1**](AccountApi.md#accountcontrollerupdateaccountv1) | **PATCH** /api/v1/account | Update authenticated account profile


# **accountControllerChangeEmailV1**
> AccountEmailResponseDto accountControllerChangeEmailV1(changeEmailDto)

Change authenticated account email

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAccountApi();
final ChangeEmailDto changeEmailDto = ; // ChangeEmailDto |

try {
    final response = api.accountControllerChangeEmailV1(changeEmailDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->accountControllerChangeEmailV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeEmailDto** | [**ChangeEmailDto**](ChangeEmailDto.md)|  |

### Return type

[**AccountEmailResponseDto**](AccountEmailResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **accountControllerChangePasswordV1**
> SuccessResponseDto accountControllerChangePasswordV1(changePasswordDto)

Change authenticated account password

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAccountApi();
final ChangePasswordDto changePasswordDto = ; // ChangePasswordDto |

try {
    final response = api.accountControllerChangePasswordV1(changePasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->accountControllerChangePasswordV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordDto** | [**ChangePasswordDto**](ChangePasswordDto.md)|  |

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **accountControllerDeleteAccountV1**
> SuccessResponseDto accountControllerDeleteAccountV1(deleteAccountDto)

Delete authenticated account

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAccountApi();
final DeleteAccountDto deleteAccountDto = ; // DeleteAccountDto |

try {
    final response = api.accountControllerDeleteAccountV1(deleteAccountDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->accountControllerDeleteAccountV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deleteAccountDto** | [**DeleteAccountDto**](DeleteAccountDto.md)|  |

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **accountControllerGetAccountV1**
> AccountResponseDto accountControllerGetAccountV1()

Get authenticated account profile

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAccountApi();

try {
    final response = api.accountControllerGetAccountV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->accountControllerGetAccountV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AccountResponseDto**](AccountResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **accountControllerUnlinkIdentityV1**
> AccountResponseDto accountControllerUnlinkIdentityV1(identityId)

Unlink authenticated account OAuth identity

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAccountApi();
final String identityId = identityId_example; // String |

try {
    final response = api.accountControllerUnlinkIdentityV1(identityId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->accountControllerUnlinkIdentityV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **identityId** | **String**|  |

### Return type

[**AccountResponseDto**](AccountResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **accountControllerUpdateAccountV1**
> AccountResponseDto accountControllerUpdateAccountV1(updateAccountDto)

Update authenticated account profile

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAccountApi();
final UpdateAccountDto updateAccountDto = ; // UpdateAccountDto |

try {
    final response = api.accountControllerUpdateAccountV1(updateAccountDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AccountApi->accountControllerUpdateAccountV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateAccountDto** | [**UpdateAccountDto**](UpdateAccountDto.md)|  |

### Return type

[**AccountResponseDto**](AccountResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
