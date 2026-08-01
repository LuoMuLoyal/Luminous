// ignore_for_file: invalid_use_of_protected_member

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/core/network/trace_context.dart';

/// In-memory session store for testing.
class _MemoryStore implements LucentSessionStore {
  LucentSessionTokens? _tokens;

  @override
  Future<LucentSessionTokens?> read() async => _tokens;

  @override
  Future<String?> readAccessToken() async => _tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => _tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

void main() {
  group('lucent network providers', () {
    late LucentDioClient dioClient;

    setUp(() {
      dioClient = LucentDioClient(
        baseUrl: 'http://localhost:3000',
        sessionStore: _MemoryStore(),
      );
    });

    tearDown(() {
      // Reset the global read point so it cannot leak across tests.
      TraceContext.lastTraceId = null;
    });

    test('lucentClientProvider returns LucentClient', () {
      final container = ProviderContainer(
        overrides: [lucentDioClientProvider.overrideWithValue(dioClient)],
      );
      addTearDown(container.dispose);

      final client = container.read(lucentClientProvider);
      expect(client, isA<LucentClient>());
    });

    test('lucentClientProvider exposes API instances', () {
      final container = ProviderContainer(
        overrides: [lucentDioClientProvider.overrideWithValue(dioClient)],
      );
      addTearDown(container.dispose);

      final client = container.read(lucentClientProvider);
      expect(client.auth, isA<AuthApi>());
      expect(client.medicines, isA<MedicinesApi>());
      expect(client.notifications, isA<NotificationsApi>());
      expect(client.reports, isA<ReportsApi>());
      expect(client.assistant, isA<AssistantApi>());
    });

    test(
      'onTraceId updates TraceContext and lastTraceIdProvider in sync',
      () async {
        final container = ProviderContainer(
          overrides: [
            lucentBaseUrlProvider.overrideWithValue('http://localhost:3000'),
            lucentSessionStoreProvider.overrideWithValue(_MemoryStore()),
          ],
        );
        addTearDown(container.dispose);

        // Reading the provider builds the real client, whose trace
        // interceptor carries the provider-wired onTraceId callback.
        final client = container.read(lucentDioClientProvider);
        final traceInterceptor = client.dio.interceptors
            .whereType<TraceInterceptor>()
            .single;

        const traceId = '11112222333344445555666677778888';
        final response = Response<dynamic>(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 200,
          headers: Headers.fromMap({
            'traceresponse': ['00-$traceId-aaaabbbbccccdddd-01'],
          }),
        );
        final handler = ResponseInterceptorHandler();

        traceInterceptor.onResponse(response, handler);
        await handler.future;

        expect(TraceContext.lastTraceId, traceId);
        expect(container.read(lastTraceIdProvider), traceId);
      },
    );
  });
}
