import 'dart:convert';

import 'package:luminous/core/database/daos/sync/pending_sync.dart';
import 'package:luminous/shared/domain/composition/layout.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 布局写入的离线队列。
///
/// 复用既有的 `pending_sync_queue`（`entityType = 'ui_layout'`），不新造机制：
/// `SyncWorker` 负责退避重试与永久失败，这里只负责把「哪个 surface、什么
/// payload、基于哪个 version」编码成队列项。
///
/// **只保留最后一次编辑**：同一 surface 连改多次时，前面的队列项没有意义
/// （服务端存的是整体文档，不是增量）。入队前先删掉该 surface 的旧项。
///
/// 抽成接口是为了让测试注入不碰数据库的替身——widget 测试没有 drift 表，
/// 真的去 enqueue 会留下未完成的 Timer。
abstract interface class LayoutSyncQueue {
  /// `entityType`，与 `SyncWorker` 注册的重放 handler 对应。
  static const entityType = 'ui_layout';

  Future<void> enqueue({
    required SurfaceId surface,
    required SurfaceLayout layout,
    int? ifVersion,
  });
}

/// 把布局编码成可重放的 payload：surface、schemaVersion、payload 文档、
/// 以及乐观并发用的 `ifVersion`。
///
/// 顶层函数而不是实例方法：编解码与「队列存在哪」无关，重放侧（组合根）只
/// 有 `PendingSyncEntry`，不应该为了解一条 payload 去构造一个队列实例。
String encodeLayoutPayload({
  required SurfaceId surface,
  required SurfaceLayout layout,
  int? ifVersion,
}) {
  return jsonEncode({
    'surface': surface.wireValue,
    'schemaVersion': layout.schemaVersion,
    'payload': layout.toJson(),
    if (ifVersion != null) 'ifVersion': ifVersion,
  });
}

/// 解出队列项；形状不认识返回 `null`（重放时跳过，不抛）。
LayoutSyncPayload? decodeLayoutPayload(PendingSyncEntry entry) {
  try {
    final json = jsonDecode(entry.payload);
    if (json is! Map) return null;
    final surface = SurfaceId.fromWire(json['surface']?.toString() ?? '');
    if (surface == null) return null;
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int) return null;
    final ifVersion = json['ifVersion'];
    return LayoutSyncPayload(
      surface: surface,
      schemaVersion: schemaVersion,
      payload: jsonEncode(json['payload']),
      ifVersion: ifVersion is int ? ifVersion : null,
    );
  } on FormatException {
    return null;
  }
}

/// 基于 `pending_sync_queue` 的实现。
final class PendingLayoutSyncQueue implements LayoutSyncQueue {
  PendingLayoutSyncQueue(this._dao);

  final PendingSyncDao _dao;

  /// operation 固定为整体覆盖：布局是文档，没有「部分更新」。
  static const operation = 'put';

  /// 串行化队列操作的链尾。
  Future<void> _tail = Future<void>.value();

  @override
  Future<void> enqueue({
    required SurfaceId surface,
    required SurfaceLayout layout,
    int? ifVersion,
  }) async {
    // 串行化：调用方是 fire-and-forget 的，同一次写入会话里可能连续触发多次
    // `write`。并发跑「查旧项 → 删 → 入队」会让两次都读到空表，结果留下两条。
    _tail = _tail.then((_) async {
      // 同一 surface 的旧项先清掉，避免队列里堆一串过期的中间状态。
      await _removeExisting(surface);
      await _dao.enqueue(
        entityType: LayoutSyncQueue.entityType,
        entityId: surface.wireValue,
        operation: operation,
        payload: encodeLayoutPayload(
          surface: surface,
          layout: layout,
          ifVersion: ifVersion,
        ),
      );
    });
    return _tail;
  }

  /// 删掉该 surface 已排队的项。
  ///
  /// `PendingSyncDao` 没有按 entityId 删除的接口（它只按 id 删），而按
  /// `fetchReady` 过滤会漏掉正在重试/退避中的项。这里直接查全表再逐个删，
  /// 队列规模是小两位数，成本可以忽略。
  Future<void> _removeExisting(SurfaceId surface) async {
    final entries = await _dao.fetchEntriesByEntity(
      entityType: LayoutSyncQueue.entityType,
      entityId: surface.wireValue,
    );
    for (final entry in entries) {
      await _dao.remove(entry.id);
    }
  }
}

/// 重放所需的字段。
final class LayoutSyncPayload {
  const LayoutSyncPayload({
    required this.surface,
    required this.schemaVersion,
    required this.payload,
    required this.ifVersion,
  });

  final SurfaceId surface;
  final int schemaVersion;

  /// 布局文档的 JSON 字符串，直接交给 `LayoutRemote.put`。
  final String payload;
  final int? ifVersion;
}
