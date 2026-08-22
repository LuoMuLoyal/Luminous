import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/today/data/datasources/ai_remote.dart';

/// SSE adapter that returns a stream of events.
class _SseAdapter implements HttpClientAdapter {
  _SseAdapter(this.events);

  final List<({String event, Map<String, dynamic> data})> events;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final buffer = StringBuffer();
    for (final e in events) {
      buffer.writeln('event:${e.event}');
      buffer.writeln('data:${jsonEncode(e.data)}');
      buffer.writeln();
    }

    final bytes = utf8.encode(buffer.toString());

    return ResponseBody(
      Stream.fromIterable([bytes]),
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }
}

/// Adapter that returns a regular JSON response.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({this.responseBody}) : statusCode = 200;

  Map<String, dynamic>? responseBody;
  int statusCode;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = jsonEncode(responseBody);

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  group('TodayAiRemoteDataSource — refresh', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    });

    Map<String, dynamic> analysisBody() => {
      'date': '2026-07-11',
      'generatedAt': '2026-07-11T08:00:00.000Z',
      'summary': '今日状态良好',
      'bullets': [],
      'actionLabel': '保持现状',
      'action': 'navigate_to_record',
      'confidenceNote': '基于最近7天数据',
      'aiGenerated': true,
    };

    Map<String, dynamic> dataBody({
      required String status,
      Map<String, dynamic>? analysis,
      String? jobId,
    }) => {
      'status': status,
      'analysis': analysis,
      if (jobId != null) 'jobId': jobId,
      'sourceVersion': 1,
      'computedVersion': 1,
      'computedAt': '2026-07-11T08:00:00.000Z',
      'retryAfterSeconds': null,
    };

    test('parses empty status', () async {
      dio.httpClientAdapter = _JsonAdapter(
        responseBody: dataBody(status: 'empty'),
      );

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );
      final result = await ds.refresh();

      expect(result.status, lucent.TodayAnalysisReadDataDtoStatusEnum.empty);
      expect(result.analysis, isNull);
    });

    test('parses ready status with analysis', () async {
      dio.httpClientAdapter = _JsonAdapter(
        responseBody: dataBody(status: 'ready', analysis: analysisBody()),
      );

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );
      final result = await ds.refresh();

      expect(result.status, lucent.TodayAnalysisReadDataDtoStatusEnum.ready);
      expect(result.analysis, isNotNull);
      expect(result.analysis!.summary, '今日状态良好');
    });

    test('parses pending status', () async {
      dio.httpClientAdapter = _JsonAdapter(
        responseBody: dataBody(status: 'pending', jobId: 'job-1'),
      );

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );
      final result = await ds.refresh();

      expect(result.status, lucent.TodayAnalysisReadDataDtoStatusEnum.pending);
      expect(result.analysis, isNull);
    });

    test('parses stale status', () async {
      dio.httpClientAdapter = _JsonAdapter(
        responseBody: dataBody(status: 'stale', analysis: analysisBody()),
      );

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );
      final result = await ds.refresh();

      expect(result.status, lucent.TodayAnalysisReadDataDtoStatusEnum.stale);
      expect(result.analysis, isNotNull);
    });

    test('parses failed status', () async {
      dio.httpClientAdapter = _JsonAdapter(
        responseBody: dataBody(status: 'failed'),
      );

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );
      final result = await ds.refresh();

      expect(result.status, lucent.TodayAnalysisReadDataDtoStatusEnum.failed);
      expect(result.analysis, isNull);
    });
  });

  group('TodayAiRemoteDataSource — generateStream', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    });

    test('summary event yields TodayAiRemoteSummaryEvent', () async {
      final adapter = _SseAdapter([
        (event: 'summary', data: {'summary': '今日分析'}),
        (event: 'done', data: {}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events.length, 1);
      expect(events[0], isA<TodayAiRemoteSummaryEvent>());
      expect((events[0] as TodayAiRemoteSummaryEvent).summary, '今日分析');
    });

    test('result event yields TodayAiRemoteResultEvent', () async {
      final adapter = _SseAdapter([
        (
          event: 'result',
          data: {
            'date': '2026-07-11',
            'generatedAt': '2026-07-11T08:00:00.000Z',
            'summary': '分析结果',
            'bullets': [],
            'actionLabel': '多喝水',
            'action': 'navigate_to_record',
            'confidenceNote': 'confidence',
            'aiGenerated': true,
          },
        ),
        (event: 'done', data: {}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events.length, 1);
      expect(events[0], isA<TodayAiRemoteResultEvent>());
      final result = events[0] as TodayAiRemoteResultEvent;
      expect(result.dto.summary, '分析结果');
      expect(result.dto.actionLabel, '多喝水');
    });

    test('empty summary string is skipped', () async {
      final adapter = _SseAdapter([
        (event: 'summary', data: {'summary': ''}),
        (event: 'summary', data: {'summary': '  '}),
        (event: 'summary', data: {'summary': 'valid'}),
        (event: 'done', data: {}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events.length, 1);
      expect((events[0] as TodayAiRemoteSummaryEvent).summary, 'valid');
    });

    test('non-Map summary data is skipped', () async {
      final adapter = _SseAdapter([
        (event: 'summary', data: {}),
        (event: 'done', data: {}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      // Empty map → summary key missing → not yielded
      expect(events, isEmpty);
    });

    test('error event maps SSE Problem Details to LucentFailure', () async {
      final adapter = _SseAdapter([
        (
          event: 'error',
          data: {
            'type': 'https://api.lumos.example/problems/dependency-unavailable',
            'title': 'Service temporarily unavailable',
            'detail': 'AI service unavailable. Try again later.',
            'code': 'DEPENDENCY_UNAVAILABLE',
            'retryable': true,
            'status': 'server_error',
          },
        ),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      expect(
        () => ds.generateStream().toList(),
        throwsA(
          isA<LucentFailure>().having(
            (e) => e.code,
            'code',
            'DEPENDENCY_UNAVAILABLE',
          ),
        ),
      );
    });

    test('error event with empty data is rejected as malformed', () async {
      final adapter = _SseAdapter([(event: 'error', data: {})]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      expect(
        () => ds.generateStream().toList(),
        throwsA(isA<FormatException>()),
      );
    });

    test('done event terminates stream', () async {
      final adapter = _SseAdapter([
        (event: 'summary', data: {'summary': 'before'}),
        (event: 'done', data: {}),
        (event: 'summary', data: {'summary': 'after'}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events.length, 1);
      expect((events[0] as TodayAiRemoteSummaryEvent).summary, 'before');
    });

    test('unknown event types are ignored', () async {
      final adapter = _SseAdapter([
        (event: 'unknown', data: {}),
        (event: 'summary', data: {'summary': 'valid'}),
        (event: 'done', data: {}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events.length, 1);
      expect((events[0] as TodayAiRemoteSummaryEvent).summary, 'valid');
    });

    test('summary + result + done sequence', () async {
      final adapter = _SseAdapter([
        (event: 'summary', data: {'summary': 'part1'}),
        (event: 'summary', data: {'summary': 'part2'}),
        (
          event: 'result',
          data: {
            'date': '2026-07-11',
            'generatedAt': '2026-07-11T08:00:00.000Z',
            'summary': 'final',
            'bullets': [],
            'actionLabel': '',
            'action': '',
            'confidenceNote': '',
            'aiGenerated': true,
          },
        ),
        (event: 'done', data: {}),
      ]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events.length, 3);
      expect(events[0], isA<TodayAiRemoteSummaryEvent>());
      expect(events[1], isA<TodayAiRemoteSummaryEvent>());
      expect(events[2], isA<TodayAiRemoteResultEvent>());
    });

    test('passes date parameter in stream body', () async {
      final adapter = _SseAdapter([(event: 'done', data: {})]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream(date: '2026-07-11').toList();

      expect(events, isEmpty);
    });

    test('null date omits date from stream body', () async {
      final adapter = _SseAdapter([(event: 'done', data: {})]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      final events = await ds.generateStream().toList();

      expect(events, isEmpty);
    });
  });
}
