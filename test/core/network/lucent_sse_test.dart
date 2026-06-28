import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_sse.dart';

/// A mock Dio adapter that returns a controlled SSE byte stream.
class _MockSseAdapter implements HttpClientAdapter {
  _MockSseAdapter(this._events);

  final List<_SseEvent> _events;
  int _callCount = 0;

  int get callCount => _callCount;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    _callCount++;
    final controller = StreamController<Uint8List>();

    Future.delayed(Duration.zero, () async {
      for (final event in _events) {
        await Future.delayed(const Duration(milliseconds: 1));
        controller.add(event.bytes);
      }
      await controller.close();
    });

    return ResponseBody(
      controller.stream,
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _SseEvent {
  _SseEvent({this.field = '', this.data = ''}) : _rawBytes = null;

  _SseEvent.raw(Uint8List bytes) : _rawBytes = bytes, field = '', data = '';

  final String field;
  final String data;
  final Uint8List? _rawBytes;

  Uint8List get bytes {
    if (_rawBytes != null) return _rawBytes;
    final lines = <String>[];
    if (field.isNotEmpty) {
      lines.add('event: $field');
    }
    if (data.isNotEmpty) {
      lines.add('data: $data');
    }
    lines.add('');
    return Uint8List.fromList('${lines.join('\n')}\n'.codeUnits);
  }
}

void main() {
  group('LucentSseClient.postJson', () {
    test('emits a single event with event field', () async {
      final adapter = _MockSseAdapter([
        _SseEvent(field: 'summary', data: '{"text": "hello"}'),
      ]);

      final dio = Dio()..httpClientAdapter = adapter;
      final client = LucentSseClient(dio: dio);

      final events = await client.postJson('/test', body: {}).toList();

      expect(adapter.callCount, equals(1));
      expect(events, hasLength(1));
      expect(events[0].event, equals('summary'));
      expect(events[0].data, equals({'text': 'hello'}));
    });

    test('emits multiple events from the stream', () async {
      final adapter = _MockSseAdapter([
        _SseEvent(field: 'chunk', data: '"part1"'),
        _SseEvent(field: 'chunk', data: '"part2"'),
        _SseEvent(field: 'done', data: '{"ok": true}'),
      ]);

      final dio = Dio()..httpClientAdapter = adapter;
      final client = LucentSseClient(dio: dio);

      final events = await client.postJson('/test', body: {}).toList();

      expect(events, hasLength(3));
      expect(events[0].event, equals('chunk'));
      expect(events[0].data, equals('part1'));
      expect(events[1].event, equals('chunk'));
      expect(events[1].data, equals('part2'));
      expect(events[2].event, equals('done'));
      expect((events[2].data as Map<String, dynamic>)['ok'], isTrue);
    });

    test('uses "message" as default event name', () async {
      final adapter = _MockSseAdapter([_SseEvent(data: '"just data"')]);

      final dio = Dio()..httpClientAdapter = adapter;
      final client = LucentSseClient(dio: dio);

      final events = await client.postJson('/test', body: {}).toList();

      expect(events, hasLength(1));
      expect(events[0].event, equals('message'));
      expect(events[0].data, equals('just data'));
    });

    test('handles multi-line data payloads', () async {
      // SSE parser concatenates multiple "data:" lines with \n
      final sseBytes = Uint8List.fromList(
        'event: result\ndata: {"ok":true\ndata: ,"count":3}\n\n'.codeUnits,
      );
      final adapter = _MockSseAdapter([_SseEvent.raw(sseBytes)]);

      final dio = Dio()..httpClientAdapter = adapter;
      final client = LucentSseClient(dio: dio);

      final events = await client.postJson('/test', body: {}).toList();

      expect(events, hasLength(1));
      expect(events[0].event, equals('result'));
      // Joined: {"ok":true\n,"count":3} — not valid JSON, but tests concatenation
      expect(events[0].data, isA<Map>());
    });

    test('emits no events for empty stream', () async {
      final adapter = _MockSseAdapter([]);

      final dio = Dio()..httpClientAdapter = adapter;
      final client = LucentSseClient(dio: dio);

      final events = await client.postJson('/test', body: {}).toList();

      expect(events, isEmpty);
    });
  });
}
