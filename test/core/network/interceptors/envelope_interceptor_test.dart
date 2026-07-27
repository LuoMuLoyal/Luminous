import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/interceptors/envelope_interceptor.dart';
import 'package:luminous/core/network/interceptors/error_interceptor.dart';

// ── Mock adapter ───────────────────────────────────────────────

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter();

  final List<_MockResponse> _queue = [];
  final List<RequestOptions> capturedRequests = [];

  void enqueue(_MockResponse response) {
    _queue.add(response);
  }

  void enqueueJson({
    int statusCode = 200,
    Map<String, dynamic>? data,
    String statusMessage = 'OK',
  }) {
    enqueue(
      _MockResponse(
        statusCode: statusCode,
        data: data,
        statusMessage: statusMessage,
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    capturedRequests.add(options);

    final response = _queue.isNotEmpty ? _queue.removeAt(0) : _MockResponse();

    final body = response.data != null
        ? Uint8List.fromList(utf8.encode(jsonEncode(response.data)))
        : Uint8List(0);

    return ResponseBody(
      body.isNotEmpty ? Stream.value(body) : const Stream.empty(),
      response.statusCode ?? 200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
      statusMessage: response.statusMessage,
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MockResponse {
  _MockResponse({this.statusCode, this.data, this.statusMessage = 'OK'});

  final int? statusCode;
  final Map<String, dynamic>? data;
  final String statusMessage;
}

// ── Helpers ────────────────────────────────────────────────────

/// Builds a Dio with [EnvelopeInterceptor] + [ErrorInterceptor] so that
/// rejected responses are also mapped to [LucentApiException].
Dio _buildDio(_MockAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(ErrorInterceptor());
  dio.interceptors.add(EnvelopeInterceptor());
  return dio;
}

LucentApiException? _extractApiException(DioException err) {
  final error = err.error;
  if (error is LucentApiException) return error;
  return null;
}

// ── Tests ──────────────────────────────────────────────────────

void main() {
  group('EnvelopeInterceptor — success responses', () {
    test('passes through when code == 0', () async {
      final adapter = _MockAdapter()
        ..enqueueJson(
          data: {
            'code': 0,
            'message': '',
            'data': {'id': 'u-1'},
          },
        );
      final dio = _buildDio(adapter);

      final response = await dio.get<Map<String, dynamic>>('/api/v1/test');
      expect(response.data?['code'], 0);
    });

    test('passes through non-envelope Map responses (no code key)', () async {
      final adapter = _MockAdapter()..enqueueJson(data: {'foo': 'bar'});
      final dio = _buildDio(adapter);

      final response = await dio.get<Map<String, dynamic>>('/api/v1/test');
      expect(response.data?['foo'], 'bar');
    });
  });

  group('EnvelopeInterceptor — business errors (code != 0)', () {
    test('rejects with LucentApiException when code != 0', () async {
      final adapter = _MockAdapter()
        ..enqueueJson(data: {'code': 401001, 'message': '未授权', 'data': null});
      final dio = _buildDio(adapter);

      try {
        await dio.get<Map<String, dynamic>>('/api/v1/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.code, 401001);
        expect(apiError.message, '未授权');
        expect(apiError.networkErrorCode, NetworkErrorCode.businessFailure);
      }
    });

    test('uses fallback message when envelope message is empty', () async {
      final adapter = _MockAdapter()
        ..enqueueJson(data: {'code': 500001, 'message': '', 'data': null});
      final dio = _buildDio(adapter);

      try {
        await dio.get<Map<String, dynamic>>('/api/v1/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.message, '业务错误 (code: 500001)');
      }
    });

    test('preserves statusCode from original response', () async {
      final adapter = _MockAdapter()
        ..enqueueJson(
          statusCode: 200,
          data: {'code': 400002, 'message': '参数错误', 'data': null},
        );
      final dio = _buildDio(adapter);

      try {
        await dio.get<Map<String, dynamic>>('/api/v1/test');
        fail('Should have thrown');
      } on DioException catch (e) {
        final apiError = _extractApiException(e);
        expect(apiError, isNotNull);
        expect(apiError!.statusCode, 200);
      }
    });

    test(
      'rejects before generated code tries to deserialize data: null',
      () async {
        // This is the key scenario: HTTP 200 + code != 0 + data: null.
        // Without EnvelopeInterceptor, the generated fromJson would throw
        // CheckedFromJsonException because data has @JsonKey(required: true).
        final adapter = _MockAdapter()
          ..enqueueJson(data: {'code': 409001, 'message': '冲突', 'data': null});
        final dio = _buildDio(adapter);

        try {
          await dio.get<Map<String, dynamic>>('/api/v1/test');
          fail('Should have thrown');
        } on DioException catch (e) {
          // The error should be a LucentApiException, NOT a
          // CheckedFromJsonException.
          final apiError = _extractApiException(e);
          expect(apiError, isNotNull);
          expect(apiError!.code, 409001);
        }
      },
    );
  });

  group('EnvelopeInterceptor — empty response body', () {
    test(
      'rejects with emptyResponse error when body is null and status 2xx',
      () async {
        final adapter = _MockAdapter()..enqueueJson(data: null);
        final dio = _buildDio(adapter);

        try {
          await dio.get<Map<String, dynamic>>('/api/v1/test');
          fail('Should have thrown');
        } on DioException catch (e) {
          final apiError = _extractApiException(e);
          expect(apiError, isNotNull);
          expect(apiError!.networkErrorCode, NetworkErrorCode.emptyResponse);
        }
      },
    );
  });

  group('EnvelopeInterceptor — skipEnvelopeCheck', () {
    test('skips envelope check when extra flag is set', () async {
      final adapter = _MockAdapter()
        ..enqueueJson(
          data: {'code': 500001, 'message': 'should be ignored', 'data': null},
        );
      final dio = _buildDio(adapter);

      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/test',
        options: Options(extra: {'skipEnvelopeCheck': true}),
      );
      // Response passes through without rejection.
      expect(response.data?['code'], 500001);
    });
  });
}
