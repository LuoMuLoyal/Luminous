import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for DeleteAccountDto
void main() {
  final DeleteAccountDto? instance = /* DeleteAccountDto(...) */ null;
  // TODO add properties to the entity

  group(DeleteAccountDto, () {
    // 当前密码（有密码的用户使用此方式确认注销）
    // String password
    test('to test the property `password`', () async {
      // TODO
    });

    // 邮箱验证码（OAuth-only 用户使用此方式确认注销）
    // String code
    test('to test the property `code`', () async {
      // TODO
    });
  });
}
