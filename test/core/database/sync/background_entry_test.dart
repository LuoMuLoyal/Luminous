import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/sync/background_entry.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/kv_test_store.dart';

class _MockSyncWorker extends Mock implements SyncWorker {}

class _FakeSessionStore implements LucentSessionStore {
  _FakeSessionStore({this.refreshToken});

  final String? refreshToken;

  @override
  Future<void> clear() async {}

  @override
  Future<LucentSessionTokens?> read() async => null;

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async {}
}

void main() {
  setUp(() {
    KvTestStore.install();
  });

  late _MockSyncWorker worker;

  setUp(() {
    worker = _MockSyncWorker();
  });

  ProviderContainer container({String? refreshToken}) {
    return ProviderContainer(
      overrides: [
        lucentSessionStoreProvider.overrideWithValue(
          _FakeSessionStore(refreshToken: refreshToken),
        ),
        syncWorkerProvider.overrideWithValue(worker),
      ],
    );
  }

  test('skips flush when no session is persisted', () async {
    final c = container();
    addTearDown(c.dispose);

    final result = await runBackgroundSync(c, registerHandlers: (_) {});

    expect(result, isTrue);
    verifyNever(() => worker.flush());
  });

  test('returns false when the flush has retryable failures', () async {
    when(
      () => worker.flush(),
    ).thenAnswer((_) async => const SyncFlushResult(retryable: 1, pending: 1));
    final c = container(refreshToken: 'refresh-token');
    addTearDown(c.dispose);
    var registered = false;

    final result = await runBackgroundSync(
      c,
      registerHandlers: (_) => registered = true,
    );

    expect(result, isFalse);
    expect(registered, isTrue);
    verify(() => worker.flush()).called(1);
  });

  test('returns true when the flush is clean', () async {
    when(
      () => worker.flush(),
    ).thenAnswer((_) async => const SyncFlushResult(synced: 2));
    final c = container(refreshToken: 'refresh-token');
    addTearDown(c.dispose);

    final result = await runBackgroundSync(c, registerHandlers: (_) {});

    expect(result, isTrue);
    verify(() => worker.flush()).called(1);
  });
}
