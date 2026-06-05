# lucent_openapi.model.OAuthAuthorizeDataDto

## Load the model package
```dart
import 'package:lucent_openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**authorizeUrl** | **String** | 第三方授权地址 |
**state** | **String** | 本次授权 state |
**expiresIn** | **num** | state 过期时间（秒） |
**callbackUri** | **String** | 客户端回跳地址。桌面端 loopback 或可信 Web 回调登录时返回。 | [optional]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
