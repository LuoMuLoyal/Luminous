import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for AppleOAuthCallbackDto
void main() {
  final AppleOAuthCallbackDto? instance = /* AppleOAuthCallbackDto(...) */ null;
  // TODO add properties to the entity

  group(AppleOAuthCallbackDto, () {
    // Apple 登录返回的 identityToken (JWT)
    // String identityToken
    test('to test the property `identityToken`', () async {
      // TODO
    });

    // Apple 登录返回的 authorizationCode（可选）
    // String authorizationCode
    test('to test the property `authorizationCode`', () async {
      // TODO
    });

    // Apple 返回的 givenName（首次登录时返回）
    // String givenName
    test('to test the property `givenName`', () async {
      // TODO
    });

    // Apple 返回的 familyName（首次登录时返回）
    // String familyName
    test('to test the property `familyName`', () async {
      // TODO
    });
  });
}
