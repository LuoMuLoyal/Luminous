import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/review/data/datasources/ai_summary_remote.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';

/// Adapter that returns an SSE stream from raw event text.
class _SseAdapter implements HttpClientAdapter {
  _SseAdapter(this.sseText);

  final String sseText;
  final int statusCode = 200;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = Uint8List.fromList(utf8.encode(sseText));
    final stream = Stream.fromIterable([bytes]);

    return ResponseBody(
      stream,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }
}

String _sseEvent(String event, Object? data) {
  return 'event: $event\ndata: ${jsonEncode(data)}\n\n';
}

void main() {
  group('ReviewAiSummaryRemoteDataSource — generateStream', () {
    late Dio dio;
    late lucent.ReportsApi api;
    late ReviewAiSummaryRemoteDataSource ds;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      api = lucent.ReportsApi(dio);
      ds = ReviewAiSummaryRemoteDataSource(api: api, dio: dio);
    });

    test('yields summary event then result event then done', () async {
      final sseText = [
        _sseEvent('summary', {'summary': '正在生成...'}),
        _sseEvent('result', {
          'range': 'last_7_days',
          'startDate': '2026-07-05',
          'endDate': '2026-07-11',
          'generatedAt': '2026-07-11T10:00:00.000Z',
          'summary': '完成总结',
          'coverage': {
            'medication': {'trackedDays': 5, 'totalDays': 7},
            'water': {'trackedDays': 3, 'totalDays': 7},
            'sleep': {'trackedDays': 0, 'totalDays': 7},
          },
          'disclaimer': '仅基于近 7 天数据。',
        }),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<ReviewAiRemoteSummaryEvent>());
      expect((events[0] as ReviewAiRemoteSummaryEvent).summary, '正在生成...');
      expect(events[1], isA<ReviewAiRemoteResultEvent>());
      expect((events[1] as ReviewAiRemoteResultEvent).dto.summary, '完成总结');
    });

    test('skips summary event with empty text', () async {
      final sseText = [
        _sseEvent('summary', {'summary': '   '}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, isEmpty);
    });

    test('skips summary event with non-string data', () async {
      final sseText = [
        _sseEvent('summary', {'summary': 123}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, isEmpty);
    });

    test('maps SSE Problem Details error event to LucentFailure', () async {
      final sseText = [
        _sseEvent('error', {
          'type': 'https://api.lumos.example/problems/dependency-timeout',
          'title': 'Service timed out',
          'detail': 'The AI service timed out. Try again later.',
          'code': 'DEPENDENCY_TIMEOUT',
          'retryable': true,
          'retryAfter': 3,
          'status': 'server_error',
        }),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      expect(
        () => ds.generateStream(ReviewAiSummaryRange.last7Days).toList(),
        throwsA(
          isA<LucentFailure>()
              .having((e) => e.code, 'code', 'DEPENDENCY_TIMEOUT')
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 3),
              ),
        ),
      );
    });

    test('rejects malformed SSE Problem Details error events', () async {
      final sseText = [_sseEvent('error', {})].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      expect(
        () => ds.generateStream(ReviewAiSummaryRange.last7Days).toList(),
        throwsA(isA<FormatException>()),
      );
    });

    test('premature stream close ends the stream without a fabricated '
        'business error', () async {
      // A connection that closes without a `done` event (server shutdown /
      // premature close) keeps stream semantics: events emitted so far are
      // delivered and the stream ends — never disguised as a business
      // Problem Details failure.
      final sseText = _sseEvent('summary', {'summary': 'partial'});

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, hasLength(1));
      expect((events[0] as ReviewAiRemoteSummaryEvent).summary, 'partial');
    });

    test(
      'connection break surfaces as a stream error, not a business failure',
      () async {
        dio.httpClientAdapter = _ErrorSseAdapter(
          DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/reports/summary/generate/stream',
            ),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(
          () => ds.generateStream(ReviewAiSummaryRange.last7Days).toList(),
          throwsA(
            isA<DioException>().having(
              (e) => e.type,
              'type',
              DioExceptionType.connectionError,
            ),
          ),
        );
      },
    );

    test('error event does not leak requestId, statusCode, stack, or raw '
        'server data', () async {
      final sseText = [
        _sseEvent('error', {
          'type': 'https://api.lumos.example/problems/dependency-unavailable',
          'title': 'Service temporarily unavailable',
          'detail': 'Try again later.',
          'code': 'DEPENDENCY_UNAVAILABLE',
          'status': 'server_error',
          // Retired / noise fields must be ignored by the parser.
          'statusCode': 503,
          'requestId': 'legacy-request-id',
          'stack': 'at Server.processRequest (server.dart:123)',
          'data': {'secret': 'raw-envelope-data'},
        }),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      Object? thrown;
      try {
        await ds.generateStream(ReviewAiSummaryRange.last7Days).toList();
        fail('expected the error event to fail the stream');
      } catch (error) {
        thrown = error;
      }

      expect(thrown, isA<LucentFailure>());
      final failure = thrown as LucentFailure;
      expect(failure.code, 'DEPENDENCY_UNAVAILABLE');
      expect(failure.statusCode, isNull);
      expect(failure.traceId, isNull);

      final text = failure.toString();
      expect(text, contains('DEPENDENCY_UNAVAILABLE'));
      expect(text, isNot(contains('requestId')));
      expect(text, isNot(contains('legacy-request-id')));
      expect(text, isNot(contains('503')));
      expect(text, isNot(contains('Try again later.')));
      expect(text, isNot(contains('raw-envelope-data')));
      expect(text, isNot(contains('server.dart')));
    });

    test('done event terminates stream immediately', () async {
      final sseText = _sseEvent('done', null);

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, isEmpty);
    });

    test(
      'passes custom range with startDate and endDate in stream body',
      () async {
        final capturedPaths = <String>[];
        final sseText = _sseEvent('done', null);

        dio.httpClientAdapter = _RecordingSseAdapter(sseText, capturedPaths);

        await ds
            .generateStream(
              ReviewAiSummaryRange.custom,
              startDate: '2026-07-01',
              endDate: '2026-07-10',
            )
            .toList();

        // Verify the POST was made to the stream endpoint
        expect(capturedPaths, isNotEmpty);
        expect(capturedPaths.first, contains('/summary/generate/stream'));
      },
    );

    test('handles result event with Map data (non-generic)', () async {
      // SSE decoder can produce Map<Object?, Object?> in some scenarios.
      // _requireMap handles Map (non-generic) by casting keys to String.
      final resultData = {
        'range': 'last_7_days',
        'startDate': '2026-07-05',
        'endDate': '2026-07-11',
        'generatedAt': '2026-07-11T10:00:00.000Z',
        'summary': 'test',
        'coverage': {
          'medication': {'trackedDays': 5, 'totalDays': 7},
          'water': {'trackedDays': 3, 'totalDays': 7},
          'sleep': {'trackedDays': 0, 'totalDays': 7},
        },
        'disclaimer': '仅基于近 7 天数据。',
      };
      final sseText = [
        _sseEvent('result', resultData),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, hasLength(1));
      expect(events[0], isA<ReviewAiRemoteResultEvent>());
      final dto = (events[0] as ReviewAiRemoteResultEvent).dto;
      expect(dto.summary, 'test');
    });

    test('unknown event types are ignored', () async {
      final sseText = [
        _sseEvent('unknown', {'foo': 'bar'}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReviewAiSummaryRange.last7Days)
          .toList();

      expect(events, isEmpty);
    });
  });
}

/// SSE adapter that records the request path.
class _RecordingSseAdapter implements HttpClientAdapter {
  _RecordingSseAdapter(this.sseText, this.recordedPaths);

  final String sseText;
  final List<String> recordedPaths;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    recordedPaths.add(options.path);
    final bytes = Uint8List.fromList(utf8.encode(sseText));
    final stream = Stream.fromIterable([bytes]);

    return ResponseBody(
      stream,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }
}

/// SSE adapter whose byte stream fails immediately, simulating a connection
/// that breaks mid-stream.
class _ErrorSseAdapter implements HttpClientAdapter {
  _ErrorSseAdapter(this.error);

  final Object error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      Stream<Uint8List>.error(error),
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }
}
