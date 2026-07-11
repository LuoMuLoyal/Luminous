import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/interceptors/error_interceptor.dart';

// ── Mock adapter ───────────────────────────────────────────────

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter();

  final List<_MockResponse> _queue = [];
  final List<RequestOptions> capturedRequests = [];
  int callCount = 0;

  void enqueue(_MockResponse response) {
    _queue.add(response);
  }

  void enqueueError({
    int? statusCode,
    Map<String, dynamic>? data,
    String statusMessage = '',
    Map<String, String>? headers,
  }) {
    enqueue(_MockResponse(
      statusCode: statusCode,
      data: data,
      statusMessage: statusMessage,
      headers: headers,
    ));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    capturedRequests.add(options);

    final response = _queue.isNotEmpty ? _queue.removeAt(0) : _MockResponse();

    if (response.errorType != null) {
      throw DioException(
        requestOptions: options,
        type: response.errorType!,
        response: response.statusCode != 200 || response.data != null
            ? Response(
                requestOptions: options,
                statusCode: response.statusCode,
                data: response.data,
              )
            : null,
      );
    }

    final body = response.data != null
        ? Uint8List.fromList(utf8.encode(jsonEncode(response.data)))
        : Uint8List(0);

    final allHeaders = <String, List<String>>{
      Headers.contentTypeHeader: ['application/json'],
      if (response.headers != null)
        for (final entry in response.headers!.entries)
          entry.key: [entry.value],
    };

    return ResponseBody(
      body.isNotEmpty ? Stream.value(body) : const Stream.empty(),
      response.statusCode ?? 200,
      headers: allHeaders,
      statusMessage: response.statusMessage,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MockResponse {
  _MockResponse({
    this.statusCode,
    this.data,
    this.statusMessage = 'OK',
    this.headers,
    this.errorType,
  });

  final int? statusCode;
  final Map<String, dynamic>? data;
  final String statusMessage;
  final Map<String, String>? headers;
  final DioExceptionType? errorType;
}

// ── Helpers ────────────────────────────────────────────────────

Dio _buildDio(_MockAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ErrorInterceptor());
  return dio;
}

LucentApiException? _extractApiException(DioException err) {
  final error = err.error;
  if (error is LucentApiException) return error;
  return null;
}

// ── Tests ──────────────────────────────────────────────────────

void main() {
  group('ErrorInterceptor — envelope message mapping', () {
    test('uses envelope message when present', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 401,
        data: {
          'code': 401002,
          'message': 'Token已过期，请重新登录',
          'data': null,
        },
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, 'Token已过期，请重新登录');
        expect(apiError.code, 401002);
        expect(apiError.statusCode, 401);
      }
    });

    test('extracts code from envelope', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 400,
        data: {
          'code': 400002,
          'message': 'validation failed',
          'data': null,
        },
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.code, 400002);
      }
    });

    test('extracts X-Request-Id header', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 500,
        data: {
          'code': 500001,
          'message': 'internal error',
          'data': null,
        },
        headers: {'X-Request-Id': 'req-abc-123'},
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.requestId, 'req-abc-123');
      }
    });

    test('requestId is null when header is absent', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 500,
        data: {
          'code': 500001,
          'message': 'err',
          'data': null,
        },
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.requestId, isNull);
      }
    });
  });

  group('ErrorInterceptor — fallback messages', () {
    test('uses fallback for connectionTimeout', () async {
      final adapter = _MockAdapter()
        ..enqueue(_MockResponse(
          statusCode: null,
          data: null,
          errorType: DioExceptionType.connectionTimeout,
        ));
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ErrorInterceptor());

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, '连接超时，请稍后再试。');
      }
    });

    test('uses fallback for sendTimeout', () async {
      final adapter = _MockAdapter()
        ..enqueue(_MockResponse(
          statusCode: null,
          data: null,
          errorType: DioExceptionType.sendTimeout,
        ));
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ErrorInterceptor());

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, '请求发送超时，请稍后再试。');
      }
    });

    test('uses fallback for connectionError', () async {
      final adapter = _MockAdapter()
        ..enqueue(_MockResponse(
          statusCode: null,
          data: null,
          errorType: DioExceptionType.connectionError,
        ));
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ErrorInterceptor());

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, '网络请求失败，请检查当前连接。');
      }
    });

    test('uses fallback for cancel', () async {
      final adapter = _MockAdapter()
        ..enqueue(_MockResponse(
          statusCode: null,
          data: null,
          errorType: DioExceptionType.cancel,
        ));
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(ErrorInterceptor());

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, '请求已取消。');
      }
    });

    test('fallback message for badResponse when no envelope', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 404,
        data: null,
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, '请求失败，请稍后再试。');
      }
    });

    test('uses fallback when envelope message is empty', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 500,
        data: {
          'code': 500001,
          'message': '',
          'data': null,
        },
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.message, '请求失败，请稍后再试。');
      }
    });
  });

  group('ErrorInterceptor — data preservation', () {
    test('preserves response data as json map', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 400,
        data: {
          'code': 400001,
          'message': 'bad request',
          'data': {'field': 'value'},
        },
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.data, isNotNull);
        expect((apiError.data as Map<String, dynamic>)['code'], 400001);
      }
    });

    test('data is null when response body is null', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 500,
        data: null,
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.data, isNull);
      }
    });
  });

  group('ErrorInterceptor — statusCode preservation', () {
    test('preserves statusCode from response', () async {
      final adapter = _MockAdapter()..enqueueError(
        statusCode: 503,
        data: {
          'code': 500003,
          'message': 'external service error',
          'data': null,
        },
      );
      final dio = _buildDio(adapter);

      try {
        await dio.get('/api/v1/test');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError!.statusCode, 503);
      }
    });
  });
}
