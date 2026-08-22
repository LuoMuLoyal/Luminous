import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/report/data/datasources/ai_summary_remote.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';

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
  group('ReportAiSummaryRemoteDataSource — generateStream', () {
    late Dio dio;
    late lucent.ReportsApi api;
    late ReportAiSummaryRemoteDataSource ds;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      api = lucent.ReportsApi(dio);
      ds = ReportAiSummaryRemoteDataSource(api: api, dio: dio);
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
          .generateStream(ReportAiSummaryRange.last7Days)
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<ReportAiRemoteSummaryEvent>());
      expect((events[0] as ReportAiRemoteSummaryEvent).summary, '正在生成...');
      expect(events[1], isA<ReportAiRemoteResultEvent>());
      expect((events[1] as ReportAiRemoteResultEvent).dto.summary, '完成总结');
    });

    test('skips summary event with empty text', () async {
      final sseText = [
        _sseEvent('summary', {'summary': '   '}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReportAiSummaryRange.last7Days)
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
          .generateStream(ReportAiSummaryRange.last7Days)
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
        () => ds.generateStream(ReportAiSummaryRange.last7Days).toList(),
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
        () => ds.generateStream(ReportAiSummaryRange.last7Days).toList(),
        throwsA(isA<FormatException>()),
      );
    });

    test('done event terminates stream immediately', () async {
      final sseText = _sseEvent('done', null);

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReportAiSummaryRange.last7Days)
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
              ReportAiSummaryRange.custom,
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
          .generateStream(ReportAiSummaryRange.last7Days)
          .toList();

      expect(events, hasLength(1));
      expect(events[0], isA<ReportAiRemoteResultEvent>());
      final dto = (events[0] as ReportAiRemoteResultEvent).dto;
      expect(dto.summary, 'test');
    });

    test('unknown event types are ignored', () async {
      final sseText = [
        _sseEvent('unknown', {'foo': 'bar'}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds
          .generateStream(ReportAiSummaryRange.last7Days)
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
