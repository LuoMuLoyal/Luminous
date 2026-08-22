import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/network/interceptors/error_interceptor.dart';

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
