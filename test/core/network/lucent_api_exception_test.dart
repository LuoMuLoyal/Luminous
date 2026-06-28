import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';

void main() {
  group('LucentApiException', () {
    test('isTokenExpired returns true for code 401002', () {
      const exception = LucentApiException(
        message: 'Token expired',
        code: 401002,
      );
      expect(exception.isTokenExpired, isTrue);
    });

    test('isTokenExpired returns false for other codes', () {
      const exception = LucentApiException(message: 'Not found', code: 404001);
      expect(exception.isTokenExpired, isFalse);
    });

    test('isRefreshTokenInvalid returns true for code 401003', () {
      const exception = LucentApiException(
        message: 'Refresh token invalid',
        code: 401003,
      );
      expect(exception.isRefreshTokenInvalid, isTrue);
    });

    test('isRefreshTokenInvalid returns false for other codes', () {
      const exception = LucentApiException(message: 'Some error', code: 500001);
      expect(exception.isRefreshTokenInvalid, isFalse);
    });

    test('toString includes message and code', () {
      const exception = LucentApiException(
        message: 'Test error',
        code: 400001,
        statusCode: 400,
        requestId: 'req-123',
      );
      final str = exception.toString();
      expect(str, contains('Test error'));
      expect(str, contains('400001'));
      expect(str, contains('400'));
      expect(str, contains('req-123'));
    });

    test('toString omits null fields', () {
      const exception = LucentApiException(message: 'Simple error');
      final str = exception.toString();
      expect(str, contains('Simple error'));
      expect(str, isNot(contains('code:')));
      expect(str, isNot(contains('statusCode:')));
    });
  });
}
