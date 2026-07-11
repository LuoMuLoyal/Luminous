import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/app_error.dart';

void main() {
  group('AppError', () {
    test('defaults kind to unknown', () {
      const error = AppError(message: 'something broke');
      expect(error.kind, AppErrorKind.unknown);
    });

    test('preserves all fields', () {
      const error = AppError(
        message: 'token expired',
        kind: AppErrorKind.auth,
        code: 401002,
        statusCode: 401,
        requestId: 'req-abc',
        cause: 'original exception',
      );

      expect(error.message, 'token expired');
      expect(error.kind, AppErrorKind.auth);
      expect(error.code, 401002);
      expect(error.statusCode, 401);
      expect(error.requestId, 'req-abc');
      expect(error.cause, 'original exception');
    });

    test('toString includes message and kind', () {
      const error = AppError(message: 'fail', kind: AppErrorKind.network);
      final str = error.toString();
      expect(str, contains('AppError(message: fail'));
      expect(str, contains('kind: AppErrorKind.network'));
    });

    test('toString includes code when present', () {
      const error = AppError(
        message: 'fail',
        code: 401002,
      );
      expect(error.toString(), contains(', code: 401002'));
    });

    test('toString includes statusCode when present', () {
      const error = AppError(
        message: 'fail',
        statusCode: 500,
      );
      expect(error.toString(), contains(', statusCode: 500'));
    });

    test('toString includes requestId when non-empty', () {
      const error = AppError(
        message: 'fail',
        requestId: 'req-123',
      );
      expect(error.toString(), contains(', requestId: req-123'));
    });

    test('toString omits requestId when empty', () {
      const error = AppError(
        message: 'fail',
        requestId: '',
      );
      expect(error.toString(), isNot(contains('requestId')));
    });

    test('toString omits requestId when null', () {
      const error = AppError(message: 'fail');
      expect(error.toString(), isNot(contains('requestId')));
    });

    test('toString omits code and statusCode when null', () {
      const error = AppError(message: 'fail');
      final str = error.toString();
      expect(str, isNot(contains('code:')));
      expect(str, isNot(contains('statusCode:')));
    });
  });

  group('AppErrorKind', () {
    test('has all expected values', () {
      expect(AppErrorKind.values, containsAll([
        AppErrorKind.network,
        AppErrorKind.auth,
        AppErrorKind.server,
        AppErrorKind.business,
        AppErrorKind.unknown,
      ]));
    });
  });
}
