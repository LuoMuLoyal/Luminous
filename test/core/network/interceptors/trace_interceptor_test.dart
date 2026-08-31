// ignore_for_file: invalid_use_of_protected_member

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/client/interceptors/trace_interceptor.dart';

void main() {
  group('TraceInterceptor.onRequest', () {
    test('injects a well-formed traceparent when none is present', () async {
      final interceptor = TraceInterceptor(skipHeaderInjection: false);
      final options = RequestOptions(path: '/api/v1/test');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.future;

      final traceparent = options.headers['traceparent'];
      expect(
        traceparent,
        matches(RegExp(r'^00-[0-9a-f]{32}-[0-9a-f]{16}-01$')),
      );
      final traceId = (traceparent as String).split('-')[1];
      expect(interceptor.lastTraceId, traceId);
      expect(
        options.extra['traceId'],
        traceId,
        reason: 'per-request traceId must be available for error binding',
      );
    });

    test(
      'passes through an existing traceparent without overwriting',
      () async {
        const existing =
            '00-aaaabbbbccccddddeeeeffff00001111-2233445566778899-01';
        final interceptor = TraceInterceptor();
        final options = RequestOptions(
          path: '/api/v1/test',
          headers: {'traceparent': existing},
        );
        final handler = RequestInterceptorHandler();

        interceptor.onRequest(options, handler);
        await handler.future;

        expect(options.headers['traceparent'], existing);
        expect(
          options.extra['traceId'],
          'aaaabbbbccccddddeeeeffff00001111',
          reason: 'passthrough must still expose the traceId for error binding',
        );
      },
    );

    test('skips injection when skipHeaderInjection is true', () async {
      final interceptor = TraceInterceptor(skipHeaderInjection: true);
      final options = RequestOptions(path: '/api/v1/test');
      final handler = RequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.future;

      expect(
        options.headers['traceparent'],
        isNull,
        reason: 'no traceparent should be injected',
      );
      expect(
        options.extra['traceId'],
        isNull,
        reason: 'no traceId set when injection is skipped',
      );
      expect(interceptor.lastTraceId, isNull);
    });

    test(
      'still tracks existing traceparent when skipHeaderInjection is true',
      () async {
        const existing =
            '00-aaaabbbbccccddddeeeeffff00001111-2233445566778899-01';
        final interceptor = TraceInterceptor(skipHeaderInjection: true);
        final options = RequestOptions(
          path: '/api/v1/test',
          headers: {'traceparent': existing},
        );
        final handler = RequestInterceptorHandler();

        interceptor.onRequest(options, handler);
        await handler.future;

        expect(
          options.headers['traceparent'],
          existing,
          reason: 'existing traceparent must pass through',
        );
        expect(interceptor.lastTraceId, 'aaaabbbbccccddddeeeeffff00001111');
        expect(
          options.extra['traceId'],
          'aaaabbbbccccddddeeeeffff00001111',
          reason: 'traceId must still be tracked for error binding',
        );
      },
    );
  });

  group('TraceInterceptor.onResponse', () {
    test(
      'updates lastTraceId and calls onTraceId from traceresponse header',
      () async {
        String? callbackTraceId;
        final interceptor = TraceInterceptor(
          onTraceId: (traceId) {
            callbackTraceId = traceId;
          },
        );
        final response = Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 200,
          headers: Headers.fromMap({
            'traceresponse': [
              '00-11112222333344445555666677778888-aaaabbbbccccdddd-01',
            ],
          }),
        );
        final handler = ResponseInterceptorHandler();

        interceptor.onResponse(response, handler);
        await handler.future;

        expect(interceptor.lastTraceId, '11112222333344445555666677778888');
        expect(callbackTraceId, '11112222333344445555666677778888');
        expect(
          response.requestOptions.extra['traceId'],
          '11112222333344445555666677778888',
          reason:
              'backend-confirmed traceId must be written back to the request',
        );
      },
    );
  });
}
