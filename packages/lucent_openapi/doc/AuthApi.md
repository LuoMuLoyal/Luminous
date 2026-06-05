# lucent_openapi.api.AuthApi

## Load the API package
```dart
import 'package:lucent_openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerCreateWechatWebAuthorizeUrlV1**](AuthApi.md#authcontrollercreatewechatwebauthorizeurlv1) | **POST** /api/v1/auth/oauth/wechat-web/authorize | 创建微信网页登录授权地址
[**authControllerForgotPasswordV1**](AuthApi.md#authcontrollerforgotpasswordv1) | **POST** /api/v1/auth/forgot-password | 忘记密码
[**authControllerLoginV1**](AuthApi.md#authcontrollerloginv1) | **POST** /api/v1/auth/login | 用户登录
[**authControllerLoginWithWechatMobileV1**](AuthApi.md#authcontrollerloginwithwechatmobilev1) | **POST** /api/v1/auth/oauth/wechat-mobile/callback | 微信移动端登录回调
[**authControllerLoginWithWechatWebV1**](AuthApi.md#authcontrollerloginwithwechatwebv1) | **POST** /api/v1/auth/oauth/wechat-web/callback | 微信网页登录回调登录
[**authControllerLogoutV1**](AuthApi.md#authcontrollerlogoutv1) | **POST** /api/v1/auth/logout | 用户登出
[**authControllerRedirectWechatWebCallbackV1**](AuthApi.md#authcontrollerredirectwechatwebcallbackv1) | **GET** /api/v1/auth/oauth/wechat-web/callback | 微信网页登录浏览器回跳
[**authControllerRefreshV1**](AuthApi.md#authcontrollerrefreshv1) | **POST** /api/v1/auth/refresh | 刷新令牌
[**authControllerRegisterV1**](AuthApi.md#authcontrollerregisterv1) | **POST** /api/v1/auth/register | 用户注册
[**authControllerResetPasswordV1**](AuthApi.md#authcontrollerresetpasswordv1) | **POST** /api/v1/auth/reset-password | 重置密码
[**authControllerSendVerificationCodeV1**](AuthApi.md#authcontrollersendverificationcodev1) | **POST** /api/v1/auth/send-verification-code | 发送邮箱验证码
[**authControllerVerifyEmailV1**](AuthApi.md#authcontrollerverifyemailv1) | **POST** /api/v1/auth/verify-email | 验证邮箱


# **authControllerCreateWechatWebAuthorizeUrlV1**
> OAuthAuthorizeResponseDto authControllerCreateWechatWebAuthorizeUrlV1(oAuthAuthorizeDto)

创建微信网页登录授权地址

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final OAuthAuthorizeDto oAuthAuthorizeDto = ; // OAuthAuthorizeDto |

try {
    final response = api.authControllerCreateWechatWebAuthorizeUrlV1(oAuthAuthorizeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerCreateWechatWebAuthorizeUrlV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **oAuthAuthorizeDto** | [**OAuthAuthorizeDto**](OAuthAuthorizeDto.md)|  | [optional]

### Return type

[**OAuthAuthorizeResponseDto**](OAuthAuthorizeResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerForgotPasswordV1**
> ForgotPasswordResponseDto authControllerForgotPasswordV1(forgotPasswordDto)

忘记密码

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final ForgotPasswordDto forgotPasswordDto = ; // ForgotPasswordDto |

try {
    final response = api.authControllerForgotPasswordV1(forgotPasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerForgotPasswordV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordDto** | [**ForgotPasswordDto**](ForgotPasswordDto.md)|  |

### Return type

[**ForgotPasswordResponseDto**](ForgotPasswordResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLoginV1**
> LoginResponseDto authControllerLoginV1(loginDto)

用户登录

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final LoginDto loginDto = ; // LoginDto |

try {
    final response = api.authControllerLoginV1(loginDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLoginV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginDto** | [**LoginDto**](LoginDto.md)|  |

### Return type

[**LoginResponseDto**](LoginResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLoginWithWechatMobileV1**
> LoginResponseDto authControllerLoginWithWechatMobileV1(oAuthCodeCallbackDto)

微信移动端登录回调

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final OAuthCodeCallbackDto oAuthCodeCallbackDto = ; // OAuthCodeCallbackDto |

try {
    final response = api.authControllerLoginWithWechatMobileV1(oAuthCodeCallbackDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLoginWithWechatMobileV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **oAuthCodeCallbackDto** | [**OAuthCodeCallbackDto**](OAuthCodeCallbackDto.md)|  |

### Return type

[**LoginResponseDto**](LoginResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLoginWithWechatWebV1**
> LoginResponseDto authControllerLoginWithWechatWebV1(oAuthCallbackDto)

微信网页登录回调登录

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final OAuthCallbackDto oAuthCallbackDto = ; // OAuthCallbackDto |

try {
    final response = api.authControllerLoginWithWechatWebV1(oAuthCallbackDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLoginWithWechatWebV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **oAuthCallbackDto** | [**OAuthCallbackDto**](OAuthCallbackDto.md)|  |

### Return type

[**LoginResponseDto**](LoginResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLogoutV1**
> SuccessResponseDto authControllerLogoutV1(logoutDto)

用户登出

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final LogoutDto logoutDto = ; // LogoutDto |

try {
    final response = api.authControllerLogoutV1(logoutDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLogoutV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logoutDto** | [**LogoutDto**](LogoutDto.md)|  |

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRedirectWechatWebCallbackV1**
> authControllerRedirectWechatWebCallbackV1(code, state)

微信网页登录浏览器回跳

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final String code = code_example; // String | OAuth 授权码
final String state = state_example; // String | 授权时生成的 state

try {
    api.authControllerRedirectWechatWebCallbackV1(code, state);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRedirectWechatWebCallbackV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| OAuth 授权码 |
 **state** | **String**| 授权时生成的 state |

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRefreshV1**
> RefreshResponseDto authControllerRefreshV1(refreshDto)

刷新令牌

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final RefreshDto refreshDto = ; // RefreshDto |

try {
    final response = api.authControllerRefreshV1(refreshDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRefreshV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshDto** | [**RefreshDto**](RefreshDto.md)|  |

### Return type

[**RefreshResponseDto**](RefreshResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRegisterV1**
> RegisterResponseDto authControllerRegisterV1(registerDto)

用户注册

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final RegisterDto registerDto = ; // RegisterDto |

try {
    final response = api.authControllerRegisterV1(registerDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRegisterV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerDto** | [**RegisterDto**](RegisterDto.md)|  |

### Return type

[**RegisterResponseDto**](RegisterResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerResetPasswordV1**
> SuccessResponseDto authControllerResetPasswordV1(resetPasswordDto)

重置密码

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final ResetPasswordDto resetPasswordDto = ; // ResetPasswordDto |

try {
    final response = api.authControllerResetPasswordV1(resetPasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerResetPasswordV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordDto** | [**ResetPasswordDto**](ResetPasswordDto.md)|  |

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerSendVerificationCodeV1**
> SendVerificationCodeResponseDto authControllerSendVerificationCodeV1(sendVerificationCodeDto)

发送邮箱验证码

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final SendVerificationCodeDto sendVerificationCodeDto = ; // SendVerificationCodeDto |

try {
    final response = api.authControllerSendVerificationCodeV1(sendVerificationCodeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerSendVerificationCodeV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sendVerificationCodeDto** | [**SendVerificationCodeDto**](SendVerificationCodeDto.md)|  |

### Return type

[**SendVerificationCodeResponseDto**](SendVerificationCodeResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerVerifyEmailV1**
> VerifyEmailResponseDto authControllerVerifyEmailV1(verifyEmailDto)

验证邮箱

### Example
```dart
import 'package:lucent_openapi/api.dart';

final api = LucentOpenapi().getAuthApi();
final VerifyEmailDto verifyEmailDto = ; // VerifyEmailDto |

try {
    final response = api.authControllerVerifyEmailV1(verifyEmailDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerVerifyEmailV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyEmailDto** | [**VerifyEmailDto**](VerifyEmailDto.md)|  |

### Return type

[**VerifyEmailResponseDto**](VerifyEmailResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
