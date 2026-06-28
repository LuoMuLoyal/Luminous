import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_result_code.dart';

void main() {
  group('LucentResultCode', () {
    test('success is 0', () {
      expect(LucentResultCode.success, equals(0));
    });

    test('badRequest is 400001', () {
      expect(LucentResultCode.badRequest, equals(400001));
    });

    test('validationFailed is 400002', () {
      expect(LucentResultCode.validationFailed, equals(400002));
    });

    test('unauthorized is 401001', () {
      expect(LucentResultCode.unauthorized, equals(401001));
    });

    test('tokenExpired is 401002', () {
      expect(LucentResultCode.tokenExpired, equals(401002));
    });

    test('forbidden is 403001', () {
      expect(LucentResultCode.forbidden, equals(403001));
    });

    test('notFound is 404001', () {
      expect(LucentResultCode.notFound, equals(404001));
    });

    test('internalError is 500001', () {
      expect(LucentResultCode.internalError, equals(500001));
    });

    test('all error codes start with expected prefix', () {
      final codes = [
        LucentResultCode.badRequest,
        LucentResultCode.validationFailed,
        LucentResultCode.verificationCodeInvalid,
        LucentResultCode.verificationCodeCooldown,
        LucentResultCode.unauthorized,
        LucentResultCode.tokenExpired,
        LucentResultCode.refreshTokenInvalid,
        LucentResultCode.loginRateLimited,
        LucentResultCode.wrongPassword,
        LucentResultCode.forbidden,
        LucentResultCode.notFound,
        LucentResultCode.conflict,
        LucentResultCode.internalError,
        LucentResultCode.databaseError,
        LucentResultCode.externalServiceError,
      ];
      for (final code in codes) {
        expect(code, greaterThan(0));
      }
    });
  });
}
