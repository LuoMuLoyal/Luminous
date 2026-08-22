import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/features/assistant/data/datasources/assistant.dart';

/// Adapter that returns an SSE stream from raw event text.
class _SseAdapter implements HttpClientAdapter {
  _SseAdapter(this.sseText);

  final String sseText;

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
      200,
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
  group('AssistantRemoteDataSource — streamMessages', () {
    late Dio dio;
    late lucent.AssistantApi api;
    late AssistantRemoteDataSource ds;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      api = lucent.AssistantApi(dio);
      ds = AssistantRemoteDataSource(api: api, dio: dio);
    });

    test('yields chunk events then result event then done', () async {
      final sseText = [
        _sseEvent('chunk', {'content': 'Hello'}),
        _sseEvent('chunk', {'content': ' world'}),
        _sseEvent('result', {
          'conversationId': 'conv-1',
          'content': 'Hello world',
          'usedTools': ['search', 'record_lookup'],
          'generatedAt': '2026-07-11T10:00:00.000Z',
          'proposedActions': [],
        }),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, hasLength(3));
      expect(events[0], isA<AssistantRemoteChunkEvent>());
      expect((events[0] as AssistantRemoteChunkEvent).content, 'Hello');
      expect(events[1], isA<AssistantRemoteChunkEvent>());
      expect((events[1] as AssistantRemoteChunkEvent).content, ' world');
      expect(events[2], isA<AssistantRemoteResultEvent>());
      final result = events[2] as AssistantRemoteResultEvent;
      expect(result.conversationId, 'conv-1');
      expect(result.content, 'Hello world');
      expect(result.usedTools, ['search', 'record_lookup']);
      expect(result.generatedAt, DateTime.parse('2026-07-11T10:00:00.000Z'));
      expect(result.proposedActions, isEmpty);
    });

    test('skips chunk with empty content', () async {
      final sseText = [
        _sseEvent('chunk', {'content': ''}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, isEmpty);
    });

    test('handles chunk with missing content key', () async {
      final sseText = [_sseEvent('chunk', {}), _sseEvent('done', null)].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, isEmpty);
    });

    test('handles result with missing optional fields', () async {
      final sseText = [_sseEvent('result', {}), _sseEvent('done', null)].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, hasLength(1));
      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.conversationId, '');
      expect(result.content, '');
      expect(result.usedTools, isEmpty);
    });

    test('handles result with non-list usedTools', () async {
      final sseText = [
        _sseEvent('result', {'usedTools': 'not-a-list'}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, hasLength(1));
      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.usedTools, isEmpty);
    });

    test('handles result with proposedActions', () async {
      final sseText = [
        _sseEvent('result', {
          'proposedActions': [
            {'type': 'create_daily_record', 'label': '记录饮水'},
            {'type': 'update_user_settings', 'label': '更新设置'},
          ],
        }),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, hasLength(1));
      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.proposedActions, hasLength(2));
      expect(result.proposedActions[0]['type'], 'create_daily_record');
    });

    test('parses toolDetails from result event', () async {
      final sseText = [
        _sseEvent('result', {
          'usedTools': ['search_medicine_leaflets'],
          'toolDetails': [
            {
              'name': 'search_medicine_leaflets',
              'label': '布洛芬缓释胶囊',
              'coverage': {'status': 'complete', 'reason': null},
              'confidence': {'level': 'high', 'reason': '向量检索命中'},
              'ambiguities': ['候选A'],
              'source': {
                'tool': 'search_medicine_leaflets',
                'generatedAt': '2026-08-17T00:00:00.000Z',
                'tables': ['cn_medicine_leaflets'],
              },
              'disclaimer': '仅供参考',
            },
          ],
        }),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, hasLength(1));
      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.toolDetails, hasLength(1));
      final detail = result.toolDetails[0];
      expect(detail['name'], 'search_medicine_leaflets');
      expect(detail['label'], '布洛芬缓释胶囊');
      expect((detail['coverage'] as Map)['status'], 'complete');
      expect((detail['confidence'] as Map)['level'], 'high');
      expect((detail['source'] as Map)['tables'], ['cn_medicine_leaflets']);
      expect(detail['disclaimer'], '仅供参考');
    });

    test('toolDetails is empty when result omits the field', () async {
      final sseText = [
        _sseEvent('result', {
          'usedTools': ['search_medicine_leaflets'],
        }),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.toolDetails, isEmpty);
    });

    test('toolDetails is empty for non-list payload', () async {
      final sseText = [
        _sseEvent('result', {'toolDetails': 'not-a-list'}),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.toolDetails, isEmpty);
    });

    test('maps the SSE Problem Details error event to LucentFailure', () async {
      final sseText = [
        _sseEvent('error', {
          'type': 'https://api.lumos.example/problems/dependency-unavailable',
          'title': 'Service temporarily unavailable',
          'detail': 'Try again later.',
          'code': 'DEPENDENCY_UNAVAILABLE',
          'retryable': true,
          'retryAfter': 5,
          'status': 'server_error',
        }),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      expect(
        () => ds.streamMessages(messages: const []).toList(),
        throwsA(
          isA<LucentFailure>()
              .having((e) => e.code, 'code', 'DEPENDENCY_UNAVAILABLE')
              .having(
                (e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 5),
              ),
        ),
      );
    });

    test('rejects malformed SSE Problem Details error events', () async {
      final sseText = [_sseEvent('error', {})].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      expect(
        () => ds.streamMessages(messages: const []).toList(),
        throwsA(isA<FormatException>()),
      );
    });

    test('done event terminates stream', () async {
      final sseText = _sseEvent('done', null);

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, isEmpty);
    });

    test('unknown event types are ignored', () async {
      final sseText = [_sseEvent('ping', {}), _sseEvent('done', null)].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      expect(events, isEmpty);
    });

    test('usedTools items are stringified', () async {
      final sseText = [
        _sseEvent('result', {
          'usedTools': [1, 2, 3],
        }),
        _sseEvent('done', null),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      final events = await ds.streamMessages(messages: const []).toList();

      final result = events[0] as AssistantRemoteResultEvent;
      expect(result.usedTools, ['1', '2', '3']);
    });

    test('handles invalid data type for event (non-map)', () async {
      // When event.data is not a Map, _requireMap should throw
      // LucentApiException
      final sseText = [_sseEvent('chunk', 'just-a-string')].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      expect(
        () => ds.streamMessages(messages: const []).toList(),
        throwsA(isA<LucentApiException>()),
      );
    });
  });

  group('AssistantRemoteDataSource — regenerateLastMessage', () {
    late Dio dio;
    late lucent.AssistantApi api;
    late AssistantRemoteDataSource ds;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      api = lucent.AssistantApi(dio);
      ds = AssistantRemoteDataSource(api: api, dio: dio);
    });

    test(
      'posts to the regenerate endpoint and parses chunk/result events',
      () async {
        String? capturedPath;
        final sseText = [
          _sseEvent('chunk', {'content': '新的'}),
          _sseEvent('result', {
            'conversationId': 'conv-1',
            'content': '新的回答',
            'usedTools': <String>[],
            'generatedAt': '2026-08-17T10:00:00.000Z',
            'proposedActions': <Object>[],
          }),
          _sseEvent('done', null),
        ].join();

        dio.httpClientAdapter = _PathCapturingSseAdapter(
          sseText,
          onFetch: (options) {
            capturedPath = options.path;
          },
        );

        final events = await ds
            .regenerateLastMessage(conversationId: 'conv-1')
            .toList();

        expect(
          capturedPath,
          '/api/v1/user/assistant/conversations/conv-1/regenerate',
        );
        expect(events, hasLength(2));
        expect((events[0] as AssistantRemoteChunkEvent).content, '新的');
        final result = events[1] as AssistantRemoteResultEvent;
        expect(result.conversationId, 'conv-1');
        expect(result.content, '新的回答');
        expect(result.usedTools, isEmpty);
        expect(result.proposedActions, isEmpty);
      },
    );

    test('maps regenerate SSE Problem Details to LucentFailure', () async {
      final sseText = [
        _sseEvent('error', {
          'type': 'https://api.lumos.example/problems/forbidden',
          'title': 'Access denied',
          'detail': 'Regeneration is not allowed.',
          'code': 'FORBIDDEN',
          'retryable': false,
          'status': 'client_error',
        }),
      ].join();

      dio.httpClientAdapter = _SseAdapter(sseText);

      expect(
        () => ds.regenerateLastMessage(conversationId: 'conv-1').toList(),
        throwsA(
          isA<LucentFailure>().having((e) => e.code, 'code', 'FORBIDDEN'),
        ),
      );
    });
  });
}

/// SSE adapter that also records the requested path via [onFetch].
class _PathCapturingSseAdapter implements HttpClientAdapter {
  _PathCapturingSseAdapter(this.sseText, {required this.onFetch});

  final String sseText;
  final void Function(RequestOptions options) onFetch;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onFetch(options);
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
