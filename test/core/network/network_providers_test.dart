import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/network/session_store.dart';

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
  });
}
