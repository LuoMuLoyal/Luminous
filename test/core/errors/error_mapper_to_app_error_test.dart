import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/error_mapper.dart';

DioException _problemError({
  int statusCode = 409,
  Map<String, dynamic> body = const {
    'type': 'https://api.lumos.example/problems/record-conflict',
    'title': 'Record conflict',
    'detail': 'A record already exists for this date.',
    'code': 'RECORD_ALREADY_EXISTS',
    'traceId': 'trace-123',
  },
}) {
  final request = RequestOptions(path: '/api/v1/test');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: statusCode,
      data: body,
      headers: Headers.fromMap(const {
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
    ),
  );
}

void main() {
  group('LucentErrorMapper.toAppError', () {
    test(
      'projects target Problem Details into the legacy AppError boundary',
      () {
        final original = _problemError();
        final error = LucentErrorMapper.toAppError(original);

        expect(error.kind, AppErrorKind.business);
        expect(error.message, 'A record already exists for this date.');
        expect(error.code, isNull);
        expect(error.statusCode, 409);
        expect(error.requestId, isNull);
        expect(error.traceId, 'trace-123');
        expect(error.cause, same(original));
      },
    );

    test('projects transport failures into network AppError metadata', () {
      final original = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final error = LucentErrorMapper.toAppError(original);

      expect(error.kind, AppErrorKind.network);
      expect(error.networkErrorCode, NetworkErrorCode.connectionTimeout);
      expect(error.statusCode, isNull);
      expect(error.requestId, isNull);
      expect(error.cause, same(original));
    });

    test('projects an existing LucentFailure without re-parsing it', () {
      const original = LucentFailure(
        kind: LucentFailureKind.authentication,
        message: 'Authentication token expired.',
        code: 'AUTH_TOKEN_EXPIRED',
        statusCode: 401,
      );

      final error = LucentErrorMapper.toAppError(original);

      expect(error.kind, AppErrorKind.auth);
      expect(error.message, original.message);
      expect(error.code, isNull);
      expect(error.statusCode, 401);
      expect(error.cause, same(original));
    });
  });
}
