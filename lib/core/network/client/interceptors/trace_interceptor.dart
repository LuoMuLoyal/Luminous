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
  TraceInterceptor({
    void Function(String traceId)? onTraceId,
    this.skipHeaderInjection = false,
  }) : _onTraceId = onTraceId;

  /// Shared cryptographically secure RNG. Creating a new [Random.secure]
  /// instance per request is expensive — reuse one instance across requests.
  static final Random _secureRandom = Random.secure();

  /// Callback invoked with the latest backend traceId parsed from the
  /// `traceresponse` response header.
  final void Function(String traceId)? _onTraceId;

  /// When true, skips generating and injecting a fresh `traceparent` header
  /// on requests that don't already carry one. Use this when another layer
  /// (e.g. Sentry's `sentry_dio` adapter) will inject `traceparent` with
  /// a traceId that belongs to the active Sentry transaction — otherwise the
  /// interceptor's random traceId would be overwritten, wasting the RNG call
  /// and temporarily exposing a stale [lastTraceId].
  ///
  /// Requests that already have a `traceparent` header are still passed
  /// through and their traceId is still tracked (existing trace context wins).
  ///
  /// Response-side tracking (`traceresponse`) is unaffected — [lastTraceId]
  /// and [onTraceId] are still updated from the backend response header.
  final bool skipHeaderInjection;

  /// The most recently seen traceId: updated with the injected `traceparent`
  /// traceId on request and with the backend `traceresponse` traceId on
  /// response.
  String? lastTraceId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final existing = _existingTraceparent(options.headers);
    if (existing != null && existing.isNotEmpty) {
      // Preserve the caller-provided trace context without overwriting it.
      lastTraceId = _traceIdFrom(existing);
      options.extra['traceId'] = lastTraceId;
      handler.next(options);
      return;
    }

    if (skipHeaderInjection) {
      handler.next(options);
      return;
    }

    final traceparent = _newTraceparent();
    options.headers['traceparent'] = traceparent;
    lastTraceId = _traceIdFrom(traceparent);
    // Per-request trace id for error binding: error/reporting code reads
    // `requestOptions.extra['traceId']` (see ErrorInterceptor).
    options.extra['traceId'] = lastTraceId;
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
      // Backend-confirmed trace id (the same one that went on the wire).
      response.requestOptions.extra['traceId'] = traceId;
    }
    handler.next(response);
  }

  /// HTTP header names are case-insensitive; some callers may set the header
  /// as `Traceparent` rather than the lowercase form used here, so match any
  /// casing.
  String? _existingTraceparent(Map<String, dynamic> headers) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'traceparent') {
        final value = entry.value;
        if (value is String && value.isNotEmpty) return value;
        if (value != null) return value.toString();
      }
    }
    return null;
  }

  /// Extracts the traceId (2nd segment) from a `traceparent`/`traceresponse`
  /// header value.
  String? _traceIdFrom(String headerValue) =>
      traceIdFromTraceHeader(headerValue);

  /// Generates a fresh `00-{traceId}-{spanId}-01` header value using
  /// [Random.secure].
  String _newTraceparent() {
    final traceId = _randomHex(_secureRandom, 16);
    final spanId = _randomHex(_secureRandom, 8);
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

/// Extracts the W3C trace id (2nd segment) from a `traceparent` /
/// `traceresponse` header value, or null when malformed.
///
/// Shared by [TraceInterceptor] and the error interceptors that bind the
/// per-request trace id (from the `traceresponse` header of error responses,
/// falling back to `options.extra['traceId']`).
String? traceIdFromTraceHeader(String headerValue) {
  final segments = headerValue.split('-');
  if (segments.length < 2) return null;
  return segments[1];
}
