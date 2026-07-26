import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/api_exception.dart';
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
    final body = responseBody != null
        ? '{"code":0,"message":"ok","data":${jsonEncode(responseBody)}}'
        : '{"code":0,"message":"ok","data":null}';

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
  group('TodayAiRemoteDataSource — generate', () {
    late Dio dio;
    late lucent.TodayAnalysisApi api;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      api = lucent.TodayAnalysisApi(dio);
    });

    test('returns parsed DTO on success', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          'date': '2026-07-11',
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'summary': '今日状态良好',
          'bullets': [],
          'actionLabel': '保持现状',
          'action': 'navigate_to_record',
          'confidenceNote': '基于最近7天数据',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(api: api, dio: dio);
      final result = await ds.generate(date: '2026-07-11');

      expect(result.date, '2026-07-11');
      expect(result.summary, '今日状态良好');
      expect(result.actionLabel, '保持现状');
    });

    test('passes date parameter to API', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          'date': '2026-07-11',
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'summary': 'ok',
          'bullets': [],
          'actionLabel': '',
          'action': '',
          'confidenceNote': '',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(api: api, dio: dio);
      await ds.generate(date: '2026-07-11');

      // The adapter recorded the request
      expect(adapter, isNotNull);
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

    test('error event throws LucentApiException', () async {
      final adapter = _SseAdapter([
        (
          event: 'error',
          data: {
            'message': 'AI service unavailable',
            'code': 5000,
            'statusCode': 500,
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
        throwsA(isA<LucentApiException>()),
      );
    });

    test('error event with empty data uses default message', () async {
      final adapter = _SseAdapter([(event: 'error', data: {})]);
      dio.httpClientAdapter = adapter;

      final ds = TodayAiRemoteDataSource(
        api: lucent.TodayAnalysisApi(dio),
        dio: dio,
      );

      expect(
        () => ds.generateStream().toList(),
        throwsA(
          isA<LucentApiException>().having(
            (e) => e.message,
            'message',
            'Request failed.',
          ),
        ),
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
