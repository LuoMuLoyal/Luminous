// ignore_for_file: invalid_use_of_protected_member

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/config/developer_settings.dart';
import 'package:luminous/core/network/client/base_url.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/client/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/core/network/client/trace_context.dart';
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';
import '../../helpers/kv_test_store.dart';

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
  setUp(() {
    KvTestStore.install();
  });

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

  group('lucentBaseUrlProvider', () {
    test('applies a stored custom endpoint that has no scheme', () async {
      KvTestStore.install(
        seed: const <String, Object>{
          'developer.apiEndpoint': 'custom',
          'developer.customApiUrl': '122.9.102.50:3000',
        },
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(developerSettingsControllerProvider.future);

      expect(container.read(lucentBaseUrlProvider), 'http://122.9.102.50:3000');
    });

    test(
      'an unusable stored endpoint falls back instead of throwing',
      () async {
        KvTestStore.install(
          seed: const <String, Object>{
            'developer.apiEndpoint': 'custom',
            'developer.customApiUrl': 'ftp://files.example.com',
          },
        );
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(developerSettingsControllerProvider.future);

        // 关键回归：provider 不得进入 error 状态（否则整棵 provider 图被
        // ProviderException 拖垮），而是回退到平台开发地址。
        expect(container.read(lucentBaseUrlProvider), LucentBaseUrl.fallback);
      },
    );

    test(
      'build-pinned LUCENT_BASE_URL is the default with no stored choice',
      () async {
        EnvReader.setTestValue(
          EnvKey.lucentBaseUrl,
          'https://api.example.test',
        );
        addTearDown(EnvReader.clearTestValues);
        KvTestStore.install();
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(developerSettingsControllerProvider.future);

        expect(
          container.read(lucentBaseUrlProvider),
          'https://api.example.test',
        );
      },
    );

    test('the dio client never sees a scheme-less base URL', () async {
      KvTestStore.install(
        seed: const <String, Object>{
          'developer.apiEndpoint': 'custom',
          'developer.customApiUrl': '122.9.102.50:3000',
        },
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(developerSettingsControllerProvider.future);

      final client = container.read(lucentDioClientProvider);
      expect(client.dio.options.baseUrl, 'http://122.9.102.50:3000');
    });
  });
}
