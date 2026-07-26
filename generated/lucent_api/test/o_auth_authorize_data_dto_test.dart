import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for OAuthAuthorizeDataDto
void main() {
  final OAuthAuthorizeDataDto? instance = /* OAuthAuthorizeDataDto(...) */ null;
  // TODO add properties to the entity

  group(OAuthAuthorizeDataDto, () {
    // 第三方授权地址
    // String authorizeUrl
    test('to test the property `authorizeUrl`', () async {
      // TODO
    });

    // 本次授权 state
    // String state
    test('to test the property `state`', () async {
      // TODO
    });

    // state 过期时间（秒）
    // num expiresIn
    test('to test the property `expiresIn`', () async {
      // TODO
    });

    // 客户端回跳地址。桌面端 loopback 或可信 Web 回调登录时返回。
    // String callbackUri
    test('to test the property `callbackUri`', () async {
      // TODO
    });
  });
}
