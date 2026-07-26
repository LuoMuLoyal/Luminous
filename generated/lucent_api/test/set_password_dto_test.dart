import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for SetPasswordDto
void main() {
  final SetPasswordDto? instance = /* SetPasswordDto(...) */ null;
  // TODO add properties to the entity

  group(SetPasswordDto, () {
    // 邮箱（OAuth-only 用户尚无邮箱时必须提供，用于同时绑定邮箱）
    // String email
    test('to test the property `email`', () async {
      // TODO
    });

    // 发往邮箱的验证码
    // String code
    test('to test the property `code`', () async {
      // TODO
    });

    // 新密码（8-32位，需包含大小写字母和数字）
    // String password
    test('to test the property `password`', () async {
      // TODO
    });
  });
}
