// ignore_for_file: prefer_initializing_formals

import 'dart:math';

import 'package:dio/dio.dart';

/// Trace interceptor: injects a W3C `traceparent` header on outgoing requests
/// and parses the `traceresponse` header of incoming responses.
///
/// The injected header follows the W3C trace context format
/// `00-{traceId}-{spanId}-01`, where `traceId` is 32 lowercase hex chars
/// (16 bytes) and `spanId` is 16 lowercase hex chars (8 bytes). A request that
/// already carries a `traceparent` header is passed through untouched so an
/// existing trace context is preserved.
class TraceInterceptor extends Interceptor {
  TraceInterceptor({void Function(String traceId)? onTraceId})
    : _onTraceId = onTraceId;

  /// Callback invoked with the latest backend traceId parsed from the
  /// `traceresponse` response header.
  final void Function(String traceId)? _onTraceId;

  /// The most recently seen traceId: updated with the injected `traceparent`
  /// traceId on request and with the backend `traceresponse` traceId on
  /// response.
  String? lastTraceId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final existing = options.headers['traceparent'];
    if (existing is String && existing.isNotEmpty) {
      // Preserve the caller-provided trace context without overwriting it.
      handler.next(options);
      return;
    }

    final traceparent = _newTraceparent();
    options.headers['traceparent'] = traceparent;
    lastTraceId = _traceIdFrom(traceparent);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final traceResponse = response.headers.value('traceresponse');
    final traceId = traceResponse == null || traceResponse.isEmpty
        ? null
        : _traceIdFrom(traceResponse);
    if (traceId != null) {
      lastTraceId = traceId;
      _onTraceId?.call(traceId);
    }
    handler.next(response);
  }

  /// Extracts the traceId (2nd segment) from a `traceparent`/`traceresponse`
  /// header value.
  String? _traceIdFrom(String headerValue) {
    final segments = headerValue.split('-');
    if (segments.length < 2) return null;
    return segments[1];
  }

  /// Generates a fresh `00-{traceId}-{spanId}-01` header value using
  /// [Random.secure].
  String _newTraceparent() {
    final random = Random.secure();
    final traceId = _randomHex(random, 16);
    final spanId = _randomHex(random, 8);
    return '00-$traceId-$spanId-01';
  }

  /// Builds [byteCount] random bytes as lowercase hex.
  String _randomHex(Random random, int byteCount) {
    final buffer = StringBuffer();
    for (var i = 0; i < byteCount; i++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
