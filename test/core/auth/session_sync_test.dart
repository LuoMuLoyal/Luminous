import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/sync/worker.dart';

import '../../helpers/kv_test_store.dart';

SessionUserSnapshot _user() => const SessionUserSnapshot(id: 'user-1');

SessionSnapshot _snapshot() => SessionSnapshot(user: _user());

/// 记录 flush 次数的替身：登录后必须触发一次重放。
///
/// 真实 `SyncWorker` 要 Connectivity、Dio 与 drift，单测里只关心「有没有被叫到」。
final class _RecordingSyncWorker extends Fake implements SyncWorker {
  int flushCalls = 0;

  @override
  Future<SyncFlushResult> flush() async {
    flushCalls += 1;
    return const SyncFlushResult();
  }
}

void main() {
  setUp(() => KvTestStore.install());

  test('applySession 登录成功后触发离线队列重放', () async {
    final worker = _RecordingSyncWorker();
    final container = ProviderContainer(
      overrides: [syncWorkerProvider.overrideWithValue(worker)],
    );
    addTearDown(container.dispose);

    await container
        .read(authSessionProvider.notifier)
        .applySession(_snapshot());

    expect(worker.flushCalls, 1);
  });

  test('applyUser 登录成功后触发离线队列重放', () {
    final worker = _RecordingSyncWorker();
    final container = ProviderContainer(
      overrides: [syncWorkerProvider.overrideWithValue(worker)],
    );
    addTearDown(container.dispose);

    container.read(authSessionProvider.notifier).applyUser(_user());

    expect(worker.flushCalls, 1);
  });

  test('登出不触发重放', () async {
    final worker = _RecordingSyncWorker();
    final container = ProviderContainer(
      overrides: [syncWorkerProvider.overrideWithValue(worker)],
    );
    addTearDown(container.dispose);

    container.read(authSessionProvider.notifier).clearLocalSession();

    expect(worker.flushCalls, 0);
  });
}
