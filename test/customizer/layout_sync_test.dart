import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/customizer/layout_repository.dart';
import 'package:luminous/core/database/database.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/repositories/cached_layout.dart';
import 'package:luminous/features/customizer/data/sync/layout_sync_queue.dart';
import 'package:luminous/shared/domain/composition/id.dart';
import 'package:luminous/shared/domain/composition/layout.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/layout_remote.dart';

SurfaceLayout _layoutWith(String id) => SurfaceLayout(
  placements: [ComponentPlacement(id: ComponentId(id))],
);

/// `payload` 是客户端自己的 JSON，服务端原样存取——这里按同形构造。
String _payloadOf(SurfaceLayout layout) => jsonEncode(layout.toJson());

late AppDatabase db;

void main() {
  setUp(() {
    KvTestStore.install();
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  group('CachedLayoutRepository 与远端接线', () {
    test('readAll 把服务端文档写进缓存', () async {
      final remote = FakeLayoutRemote(
        remoteDocs: {
          SurfaceId.today: jsonEncode({
            'schemaVersion': SurfaceLayout.currentSchemaVersion,
            'placements': [
              {'id': 'water.trend', 'size': 'compact'},
            ],
          }),
        },
      );
      final repository = CachedLayoutRepository(
        cache: LayoutCache(KvStore.instance),
        remote: remote,
        syncQueue: PendingLayoutSyncQueue(db.pendingSyncDao),
      );

      final result = await repository.readAll().run();
      final layouts = result.getOrElse((_) => const {});

      expect(layouts[SurfaceId.today]?.placements.single.id.value, 'water.trend');
      // 已落缓存：下一次直接读本地就有。
      final cached = await LayoutCache(KvStore.instance).readAll();
      expect(cached[SurfaceId.today]?.placements.single.id.value, 'water.trend');
    });

    test('远端失败但有缓存时沿用缓存，不把失败抛给页面', () async {
      await LayoutCache(KvStore.instance).write(
        SurfaceId.record,
        _layoutWith('calendar.strip'),
      );
      final remote = FakeLayoutRemote()
        ..failure = LucentFailure.unknown(message: 'offline');
      final repository = CachedLayoutRepository(
        cache: LayoutCache(KvStore.instance),
        remote: remote,
        syncQueue: PendingLayoutSyncQueue(db.pendingSyncDao),
      );

      final layouts = (await repository.readAll().run()).getOrElse(
        (_) => const {},
      );
      expect(layouts[SurfaceId.record]?.placements.single.id.value, 'calendar.strip');
    });

    test('write 把 payload 推给远端并带上 schemaVersion', () async {
      String? sentPayload;
      int? sentSchema;
      final remote = FakeLayoutRemote()
        ..onPut = (surface, payload, ifVersion) {
          expect(surface, SurfaceId.today);
          sentPayload = payload;
          sentSchema = const LayoutWireProbe().schemaOf(payload);
        };
      final repository = CachedLayoutRepository(
        cache: LayoutCache(KvStore.instance),
        remote: remote,
        syncQueue: PendingLayoutSyncQueue(db.pendingSyncDao),
      );

      await repository.write(SurfaceId.today, _layoutWith('summary.metrics')).run();

      expect(sentSchema, SurfaceLayout.currentSchemaVersion);
      expect(jsonDecode(sentPayload!), isA<Map<String, Object?>>());
    });

    test('409 冲突时采纳服务端文档并写回缓存', () async {
      final serverLayout = _layoutWith('dose.risk_overview');
      final remote = FakeLayoutRemote()
        ..failure = LucentFailure(
          kind: LucentFailureKind.business,
          message: 'conflict',
          statusCode: 409,
          errors: {
            'current': {
              'surface': 'today',
              'version': 7,
              'schemaVersion': SurfaceLayout.currentSchemaVersion,
              'payload': jsonDecode(_payloadOf(serverLayout)),
            },
          },
        );
      final repository = CachedLayoutRepository(
        cache: LayoutCache(KvStore.instance),
        remote: remote,
        syncQueue: PendingLayoutSyncQueue(db.pendingSyncDao),
      );

      final result = await repository
          .write(SurfaceId.today, _layoutWith('summary.metrics'))
          .run();

      expect(
        result.getOrElse((_) => SurfaceLayout.empty).placements.single.id.value,
        'dose.risk_overview',
      );
      final cached = await LayoutCache(KvStore.instance).readAll();
      expect(
        cached[SurfaceId.today]?.placements.single.id.value,
        'dose.risk_overview',
      );
    });

    test('非 409 失败时入离线队列，同 surface 只保留最后一次', () async {
      final remote = FakeLayoutRemote()
        ..failure = LucentFailure.unknown(message: 'offline');
      final repository = CachedLayoutRepository(
        cache: LayoutCache(KvStore.instance),
        remote: remote,
        syncQueue: PendingLayoutSyncQueue(db.pendingSyncDao),
      );

      await repository.write(SurfaceId.today, _layoutWith('water.trend')).run();
      await repository
          .write(SurfaceId.today, _layoutWith('summary.metrics'))
          .run();
      // 入队是 fire-and-forget（不阻塞用户确认），等它落库。
      await pumpEventQueue();

      final entries = await db.pendingSyncDao.fetchEntriesByEntity(
        entityType: LayoutSyncQueue.entityType,
        entityId: SurfaceId.today.wireValue,
      );
      // 连改两次仍只有一条：布局是整份文档，中间状态没有重放价值。
      expect(entries, hasLength(1));
      final decoded = decodeLayoutPayload(entries.single)!;
      expect(decoded.surface, SurfaceId.today);
      expect(decoded.payload, contains('summary.metrics'));
    });

    test('409 冲突不进入离线队列', () async {
      final remote = FakeLayoutRemote()
        ..failure = LucentFailure(
          kind: LucentFailureKind.business,
          message: 'conflict',
          statusCode: 409,
          errors: {
            'current': {
              'surface': 'today',
              'version': 9,
              'schemaVersion': SurfaceLayout.currentSchemaVersion,
              'payload': jsonDecode(_payloadOf(_layoutWith('water.trend'))),
            },
          },
        );
      final repository = CachedLayoutRepository(
        cache: LayoutCache(KvStore.instance),
        remote: remote,
        syncQueue: PendingLayoutSyncQueue(db.pendingSyncDao),
      );

      await repository
          .write(SurfaceId.today, _layoutWith('summary.metrics'))
          .run();
      await pumpEventQueue();

      final entries = await db.pendingSyncDao.fetchEntriesByEntity(
        entityType: LayoutSyncQueue.entityType,
        entityId: SurfaceId.today.wireValue,
      );
      expect(entries, isEmpty);
    });
  });

  test('layoutRepositoryProvider 用真实装配时可被覆盖', () {
    final container = ProviderContainer(
      overrides: [fakeLayoutRepositoryOverride()],
    );
    addTearDown(container.dispose);
    expect(container.read(layoutRepositoryProvider), isA<CachedLayoutRepository>());
  });
}

/// 从 payload JSON 里读回 schemaVersion，避免测试依赖内部编码细节。
final class LayoutWireProbe {
  const LayoutWireProbe();

  int? schemaOf(String payload) {
    final decoded = jsonDecode(payload);
    return decoded is Map ? decoded['schemaVersion'] as int? : null;
  }
}
