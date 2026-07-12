import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_mapper.dart';

void main() {
  group('LucentErrorMapper.toAppError', () {
    test('maps LucentApiException with auth code to auth kind', () {
      const exception = LucentApiException(
        message: 'Token expired',
        code: 401002,
        statusCode: 401,
      );
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.kind, equals(AppErrorKind.auth));
      expect(error.message, equals('Token expired'));
      expect(error.code, equals(401002));
      expect(error.statusCode, equals(401));
      expect(error.cause, same(exception));
    });

    test('maps forbidden to auth kind', () {
      const exception = LucentApiException(
        message: 'Forbidden',
        code: 403001,
        statusCode: 403,
      );
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.kind, equals(AppErrorKind.auth));
    });

    test('maps 5xx to server kind', () {
      const exception = LucentApiException(
        message: 'Internal error',
        code: 500001,
        statusCode: 500,
      );
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.kind, equals(AppErrorKind.server));
    });

    test('maps 502 without envelope code to server kind', () {
      const exception = LucentApiException(
        message: 'Bad gateway',
        statusCode: 502,
      );
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.kind, equals(AppErrorKind.server));
    });

    test('maps DioException connectionTimeout to network kind', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final error = LucentErrorMapper.toAppError(dioError);
      expect(error.kind, equals(AppErrorKind.network));
      expect(error.message, equals('连接超时，请稍后再试。'));
      expect(error.cause, same(dioError));
    });

    test('maps DioException connectionError to network kind', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final error = LucentErrorMapper.toAppError(dioError);
      expect(error.kind, equals(AppErrorKind.network));
    });

    test('maps 4xx with business code to business kind', () {
      const exception = LucentApiException(
        message: 'Verification code cooldown',
        code: 400101,
        statusCode: 400,
      );
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.kind, equals(AppErrorKind.business));
    });

    test('maps wrong password to business kind', () {
      const exception = LucentApiException(
        message: 'Wrong password',
        code: 401005,
        statusCode: 401,
      );
      // 401005 is wrongPassword — HTTP 401 but not in the auth code set,
      // so it falls through to the business category.
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.kind, equals(AppErrorKind.business));
    });

    test('maps plain Exception to unknown kind', () {
      final error = LucentErrorMapper.toAppError(Exception('something'));
      expect(error.kind, equals(AppErrorKind.unknown));
      expect(error.message, equals('发生了未预期的错误。'));
    });

    test('preserves requestId from LucentApiException', () {
      const exception = LucentApiException(
        message: 'fail',
        statusCode: 500,
        requestId: 'req-abc-123',
      );
      final error = LucentErrorMapper.toAppError(exception);
      expect(error.requestId, equals('req-abc-123'));
    });

    test('preserves cause as original thrown object', () {
      final original = Exception('original cause');
      final error = LucentErrorMapper.toAppError(original);
      expect(error.cause, same(original));
    });

    test('DioException with LucentApiException error field', () {
      const inner = LucentApiException(
        message: 'Inner',
        code: 401002,
        statusCode: 401,
      );
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: inner,
      );
      final error = LucentErrorMapper.toAppError(dioError);
      expect(error.kind, equals(AppErrorKind.auth));
      expect(error.message, equals('Inner'));
      expect(error.code, equals(401002));
    });
  });
}
