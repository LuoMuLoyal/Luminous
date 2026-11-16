import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/shell/data/repositories/cached_nav_config.dart';
import 'package:luminous/features/shell/data/sync/nav_config_sync.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/repositories/nav_config_remote.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

import '../helpers/kv_test_store.dart';

/// `NavConfigSync` 的推送 / 拉取 / 降级语义。
///
/// 用替身而不是真网络：这一层的职责是「什么时候推、什么时候采纳、失败时去哪」，
/// 远端请求本身由 `LucentLayoutRemote` 与其适配器覆盖。
void main() {
  late KvStore store;
  late CachedNavConfigRepository local;
  late _FakeRemote remote;
  late _FakeQueue queue;
  late NavConfigSync sync;

  const customised = NavConfig(
    tabs: [
      TabPlacement(tabId: TabId.today, order: 0, customLabel: '总结'),
      TabPlacement(tabId: TabId.record, order: 1),
      TabPlacement(tabId: TabId.medicine, order: 2),
      TabPlacement(tabId: TabId.review, order: 3),
      TabPlacement(tabId: TabId.mine, order: 4),
    ],
  );

  setUp(() {
    store = KvTestStore.install();
    local = CachedNavConfigRepository(store);
    remote = _FakeRemote();
    queue = _FakeQueue();
    sync = NavConfigSync(remote: remote, syncQueue: queue, local: local);
  });

  group('surface', () {
    test('is exactly "tab" — no extra prefix or suffix', () {
      expect(NavConfigSync.surface, SurfaceId.tab);
      expect(SurfaceId.tab.wireValue, 'tab');
    });
  });

  group('push', () {
    test('sends the config to the tab surface', () async {
      final accepted = await sync.push(customised);

      expect(accepted, isTrue);
      expect(remote.puts, hasLength(1));
      expect(remote.puts.single.surface, SurfaceId.tab);
      expect(queue.entries, isEmpty);
    });

    test('the payload round-trips through the wire format', () async {
      await sync.push(customised);

      final decoded = decodeNavConfigPayload(remote.puts.single.payload);
      expect(decoded, customised);
    });

    test('queues for retry when the remote rejects the write', () async {
      remote.putAccepted = false;

      final accepted = await sync.push(customised);

      expect(accepted, isFalse);
      expect(queue.entries, hasLength(1));
      expect(queue.entries.single.surface, SurfaceId.tab);
    });

    test('the queued payload matches what push sent', () async {
      remote.putAccepted = false;
      await sync.push(customised);

      expect(decodeNavConfigPayload(queue.entries.single.payload), customised);
    });
  });

  group('pull', () {
    test('adopts a remote config into the local store', () async {
      remote.fetchPayload = encodeNavConfigPayload(customised);

      final adopted = await sync.pull();

      expect(adopted, isTrue);
      expect(local.read(), customised);
    });

    test('returns false when the remote has nothing stored', () async {
      remote.fetchPayload = null;

      expect(await sync.pull(), isFalse);
      expect(local.read().isDefault, isTrue);
    });

    test('returns false when the local copy already matches', () async {
      await local.write(customised);
      remote.fetchPayload = encodeNavConfigPayload(customised);

      expect(await sync.pull(), isFalse);
    });

    test('keeps the local copy when the remote doc is unreadable', () async {
      await local.write(customised);
      remote.fetchPayload = '{"schemaVersion":999}';

      expect(await sync.pull(), isFalse);
      expect(local.read(), customised);
    });

    test('keeps the local copy when the fetch fails', () async {
      await local.write(customised);
      remote.fetchFailure = _networkFailure;

      expect(await sync.pull(), isFalse);
      expect(local.read(), customised);
    });

    test(
      'never clobbers a customised local config with an empty remote',
      () async {
        await local.write(customised);
        remote.fetchPayload = null;

        await sync.pull();

        expect(local.read(), customised);
      },
    );
  });

  group('payload codec', () {
    test('round-trips the default config', () {
      final decoded = decodeNavConfigPayload(
        encodeNavConfigPayload(const NavConfig()),
      );

      expect(decoded, isNotNull);
      expect(decoded!.isDefault, isTrue);
    });

    test('rejects malformed JSON', () {
      expect(decodeNavConfigPayload('not json'), isNull);
    });
  });
}

const LucentFailure _networkFailure = LucentFailure(
  kind: LucentFailureKind.network,
  message: 'offline',
  traceId: 'trace',
);

class _PutCall {
  const _PutCall(this.surface, this.payload);

  final SurfaceId surface;
  final String payload;
}

class _QueuedEntry {
  const _QueuedEntry(this.surface, this.payload);

  final SurfaceId surface;
  final String payload;
}

class _FakeRemote implements NavConfigRemote {
  final List<_PutCall> puts = [];
  bool putAccepted = true;
  LucentFailure? fetchFailure;
  String? fetchPayload;

  @override
  Future<bool> put({
    required SurfaceId surface,
    required int schemaVersion,
    required String payload,
  }) async {
    puts.add(_PutCall(surface, payload));
    return putAccepted;
  }

  @override
  Future<({String? payload, LucentFailure? failure})> fetch(
    SurfaceId surface,
  ) async {
    final failure = fetchFailure;
    if (failure != null) return (payload: null, failure: failure);
    return (payload: fetchPayload, failure: null);
  }
}

class _FakeQueue implements NavConfigSyncQueue {
  final List<_QueuedEntry> entries = [];

  @override
  Future<void> enqueue({
    required SurfaceId surface,
    required int schemaVersion,
    required String payload,
  }) async {
    entries.add(_QueuedEntry(surface, payload));
  }
}
