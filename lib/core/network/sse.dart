import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_code.dart';

// ignore_for_file: prefer_initializing_formals

class LucentSseEvent {
  const LucentSseEvent({required this.event, required this.data});

  final String event;
  final Object? data;
}

class LucentSseClient {
  LucentSseClient({
    required Dio dio,
    this.reconnect = false,
    this.maxReconnects = 3,
  }) : _dio = dio;

  final Dio _dio;

  /// When `true`, automatically re-requests the stream if it closes due
  /// to a network error. Has no effect on normal stream completion.
  final bool reconnect;

  /// Maximum number of reconnection attempts when [reconnect] is enabled.
  final int maxReconnects;

  Stream<LucentSseEvent> postJson(
    String path, {
    required Map<String, Object?> body,
  }) async* {
    var reconnectAttempts = 0;

    while (true) {
      try {
        await for (final event in _postAndDecode(path, body)) {
          yield event;
        }
        return;
      } on DioException catch (e) {
        if (!reconnect ||
            reconnectAttempts >= maxReconnects ||
            !_isReconnectable(e)) {
          rethrow;
        }
        reconnectAttempts++;
        // Exponential backoff: 1s, 2s, 4s, ...
        await Future<void>.delayed(
          Duration(seconds: 1 << (reconnectAttempts - 1)),
        );
        // Loop and retry.
        continue;
      }
    }
  }

  bool _isReconnectable(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  Stream<LucentSseEvent> _postAndDecode(
    String path,
    Map<String, Object?> body,
  ) async* {
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
        // SSE 是长连接流式响应，receiveTimeout 是两次数据事件之间的
        // 最大间隔。AI 生成可能需要 >10s 来产出第一个 chunk，设为 0
        // （不限超时）避免流提前中断。
        receiveTimeout: Duration.zero,
      ),
    );

    final responseBody = response.data;
    if (responseBody == null) {
      throw const LucentApiException(
        message: 'SSE stream response is empty.',
        networkErrorCode: NetworkErrorCode.emptyStreamResponse,
      );
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

    await for (final chunk in byteStream.cast<List<int>>().transform(
      utf8.decoder,
    )) {
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
