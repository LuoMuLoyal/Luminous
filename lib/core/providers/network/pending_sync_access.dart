/// 待同步队列的只读访问接缝。
///
/// `lib/core/providers/` 是 presentation 层唯一允许依赖的 core 子树。
/// 这里用**包装类 + 数据类**把 `core/database` 的类型挡在展示层之外：
/// core 内部照常 import 数据库，presentation 只见到本文件声明的类型。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/sync/pending_sync.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';

/// 一条永久失败的同步项（展示层视角的只读视图）。
class PendingSyncFailure {
  const PendingSyncFailure({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload = '{}',
    required this.createdAt,
    required this.retryCount,
    required this.maxRetry,
    this.lastError,
    this.errorDetails,
  });

  factory PendingSyncFailure.fromEntry(PendingSyncEntry entry) {
    return PendingSyncFailure(
      id: entry.id,
      entityType: entry.entityType,
      entityId: entry.entityId,
      operation: entry.operation,
      payload: entry.payload,
      createdAt: entry.createdAt,
      retryCount: entry.retryCount,
      maxRetry: entry.maxRetry,
      lastError: entry.lastError,
      errorDetails: entry.errorDetails == null
          ? null
          : PendingSyncErrorView.fromDetails(entry.errorDetails!),
    );
  }

  final String id;
  final String entityType;
  final String? entityId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetry;
  final String? lastError;
  final PendingSyncErrorView? errorDetails;
}

/// 队列项的结构化错误详情（展示层只读视图）。
class PendingSyncErrorView {
  const PendingSyncErrorView({
    this.kind,
    this.code,
    this.networkErrorCode,
    this.statusCode,
    this.message,
    this.traceId,
    this.raw,
  });

  factory PendingSyncErrorView.fromDetails(PendingSyncErrorDetails d) {
    return PendingSyncErrorView(
      kind: d.kind,
      code: d.code,
      networkErrorCode: d.networkErrorCode,
      statusCode: d.statusCode,
      message: d.message,
      traceId: d.traceId,
      raw: d.raw,
    );
  }

  final LucentFailureKind? kind;
  final String? code;
  final NetworkErrorCode? networkErrorCode;
  final int? statusCode;
  final String? message;
  final String? traceId;
  final String? raw;
}

/// 待同步队列的访问器。
class PendingSyncQueue {
  const PendingSyncQueue(this._ref);

  final Ref _ref;

  Future<List<PendingSyncFailure>> permanentlyFailed() async {
    final entries = await _ref
        .read(pendingSyncDaoProvider)
        .fetchPermanentlyFailed();
    return entries.map(PendingSyncFailure.fromEntry).toList();
  }

  Future<int> permanentlyFailedCount() {
    return _ref.read(syncFailedCountProvider.future);
  }

  Future<void> retryAll(List<String> ids) async {
    final dao = _ref.read(pendingSyncDaoProvider);
    await Future.wait(ids.map(dao.resetForRetry));
    await _ref.read(syncWorkerProvider).flush();
  }

  Future<void> discard(String id) {
    return _ref.read(pendingSyncDaoProvider).remove(id);
  }
}

/// 队列访问器的 provider。
final pendingSyncQueueProvider = Provider<PendingSyncQueue>(
  PendingSyncQueue.new,
);

/// Mine 页横幅用的失败计数（与 syncFailedCountProvider 同源）。
final pendingSyncFailedCountProvider = FutureProvider<int>((ref) {
  return ref.watch(pendingSyncQueueProvider).permanentlyFailedCount();
});

/// 永久失败的队列项列表。
final pendingSyncFailuresProvider = FutureProvider<List<PendingSyncFailure>>((
  ref,
) {
  return ref.watch(pendingSyncQueueProvider).permanentlyFailed();
});
