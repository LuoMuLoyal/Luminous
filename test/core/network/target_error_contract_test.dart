import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/interceptors/error_interceptor.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';

const _problemBody = <String, dynamic>{
  'type': 'https://api.lumos.example/problems/record-conflict',
  'title': 'Record conflict',
  'detail': 'A record already exists for this date.',
  'code': 'RECORD_ALREADY_EXISTS',
  'retryable': false,
  'traceId': 'trace-123',
};

DioException _problemError({
  int statusCode = 409,
  Object? body = _problemBody,
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
  group('LucentErrorMapper target contract', () {
    test('maps application/problem+json into LucentFailure', () {
      final failure = LucentErrorMapper.fromObject(_problemError());

      expect(failure.kind, LucentFailureKind.business);
      expect(failure.message, 'A record already exists for this date.');
      expect(failure.code, 'RECORD_ALREADY_EXISTS');
      expect(failure.statusCode, 409);
      expect(failure.retryable, isFalse);
      expect(failure.traceId, 'trace-123');
      expect(failure.toString(), isNot(contains('requestId')));
    });

    test('rejects the retired numeric envelope instead of parsing it', () {
      expect(
        () => LucentErrorMapper.fromObject(
          _problemError(
            body: const {'code': 409001, 'message': 'Conflict', 'data': null},
          ),
        ),
        throwsFormatException,
      );
    });

    test('maps transport failures without inventing HTTP problem fields', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = LucentErrorMapper.fromObject(error);

      expect(failure.kind, LucentFailureKind.network);
      expect(failure.statusCode, isNull);
      expect(failure.code, isNull);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionTimeout);
      expect(failure.toString(), isNot(contains('requestId')));
    });

    test('maps every transport failure to LucentFailure.network', () {
      const cases = <(DioExceptionType, NetworkErrorCode)>[
        (DioExceptionType.connectionError, NetworkErrorCode.connectionError),
        (
          DioExceptionType.connectionTimeout,
          NetworkErrorCode.connectionTimeout,
        ),
        (DioExceptionType.sendTimeout, NetworkErrorCode.sendTimeout),
        (DioExceptionType.receiveTimeout, NetworkErrorCode.receiveTimeout),
        (DioExceptionType.badCertificate, NetworkErrorCode.badCertificate),
      ];

      for (final (type, expectedCode) in cases) {
        final failure = LucentErrorMapper.fromObject(
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/test'),
            type: type,
          ),
        );

        expect(
          failure.kind,
          LucentFailureKind.network,
          reason: 'unexpected kind for $type',
        );
        expect(
          failure.networkErrorCode,
          expectedCode,
          reason: 'unexpected networkErrorCode for $type',
        );
        expect(failure.statusCode, isNull);
        expect(failure.code, isNull);
      }
    });

    test('rejects a missing body despite the problem+json media type', () {
      expect(
        () => LucentErrorMapper.fromObject(_problemError(body: null)),
        throwsFormatException,
      );
      expect(
        () => LucentErrorMapper.fromObject(_problemError(body: '')),
        throwsFormatException,
      );
    });

    test('rejects a non-object body despite the problem+json media type', () {
      expect(
        () => LucentErrorMapper.fromObject(_problemError(body: 'oops')),
        throwsFormatException,
      );
      expect(
        () => LucentErrorMapper.fromObject(_problemError(body: <int>[1, 2])),
        throwsFormatException,
      );
    });

    test('rejects a wrong media type even with a problem-shaped body', () {
      final request = RequestOptions(path: '/api/v1/test');
      final error = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: 503,
          data: _problemBody,
          headers: Headers.fromMap(const {
            Headers.contentTypeHeader: ['text/html'],
          }),
        ),
      );

      expect(() => LucentErrorMapper.fromObject(error), throwsFormatException);
    });

    test('rejects a numeric code field', () {
      expect(
        () => LucentErrorMapper.fromObject(
          _problemError(
            body: <String, dynamic>{..._problemBody, 'code': 409001},
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejects a negative retryAfter field', () {
      expect(
        () => LucentErrorMapper.fromObject(
          _problemError(
            body: <String, dynamic>{..._problemBody, 'retryAfter': -3},
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejects a fractional retryAfter field', () {
      expect(
        () => LucentErrorMapper.fromObject(
          _problemError(
            body: <String, dynamic>{..._problemBody, 'retryAfter': 2.5},
          ),
        ),
        throwsFormatException,
      );
    });
  });

  test(
    'ErrorInterceptor attaches LucentFailure to the rejected DioException',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = _ProblemAdapter();
      dio.interceptors.add(ErrorInterceptor());

      try {
        await dio.get('/api/v1/test');
        fail('expected a DioException');
      } on DioException catch (error) {
        expect(error.error, isA<LucentFailure>());
        final failure = error.error! as LucentFailure;
        expect(failure.code, 'RECORD_ALREADY_EXISTS');
      }
    },
  );
}

final class _ProblemAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = Uint8List.fromList(utf8.encode(jsonEncode(_problemBody)));
    return ResponseBody(
      Stream.value(body),
      409,
      headers: const {
        Headers.contentTypeHeader: ['application/problem+json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
