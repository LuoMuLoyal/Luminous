import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';

class LucentSseEvent {
  const LucentSseEvent({
    required this.event,
    required this.data,
  });

  final String event;
  final Object? data;
}

class LucentSseClient {
  LucentSseClient({required this._dio});

  final Dio _dio;

  Stream<LucentSseEvent> postJson(
    String path, {
    required Map<String, Object?> body,
  }) async* {
    final headers = <String, Object?>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Content-Type': Headers.jsonContentType,
    };

    final response = await _dio.post<ResponseBody>(
      path,
      data: body,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
      ),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      throw const LucentApiException(message: 'Lucent SSE response is empty.');
    }

    yield* _decode(responseBody.stream);
  }

  Stream<LucentSseEvent> _decode(Stream<Uint8List> byteStream) async* {
    var buffer = '';
    String? eventName;
    final dataLines = <String>[];

    Future<LucentSseEvent?> flushEvent() async {
      if (eventName == null && dataLines.isEmpty) {
        return null;
      }

      final payloadText = dataLines.join('\n');
      final payload = payloadText.isEmpty ? null : jsonDecode(payloadText);
      final event = LucentSseEvent(
        event: eventName ?? 'message',
        data: payload,
      );
      eventName = null;
      dataLines.clear();
      return event;
    }

    await for (final chunk in byteStream
        .cast<List<int>>()
        .transform(utf8.decoder)) {
      buffer += chunk;
      var lineBreakIndex = buffer.indexOf('\n');
      while (lineBreakIndex >= 0) {
        final line = buffer.substring(0, lineBreakIndex).replaceAll('\r', '');
        buffer = buffer.substring(lineBreakIndex + 1);

        if (line.isEmpty) {
          final event = await flushEvent();
          if (event != null) {
            yield event;
          }
        } else if (line.startsWith('event:')) {
          eventName = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          dataLines.add(line.substring(5).trimLeft());
        }

        lineBreakIndex = buffer.indexOf('\n');
      }
    }

    final tail = buffer.replaceAll('\r', '');
    if (tail.isNotEmpty) {
      if (tail.startsWith('event:')) {
        eventName = tail.substring(6).trim();
      } else if (tail.startsWith('data:')) {
        dataLines.add(tail.substring(5).trimLeft());
      }
    }

    final finalEvent = await flushEvent();
    if (finalEvent != null) {
      yield finalEvent;
    }
  }
}
