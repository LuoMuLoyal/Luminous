// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/daos/health_context.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/health_context.dart';
import 'package:luminous/features/health_context/data/utils/health_context_snapshot_codec.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';

/// Cache-first implementation of [HealthContextRepository].
///
/// Read: returns cached snapshot immediately + background refresh (throttled 30s).
/// If cache is empty, fetches from network and populates cache — a cache write
/// failure on this path is a failure of the request itself (path A), so it
/// surfaces as a Left. Background-refresh cache writes are best-effort (path B):
/// they are logged and the cached snapshot is still returned.
///
/// Write: attempts remote mutation; on success, replaces the cached snapshot.
/// On network failure ([DioException]), enqueues the HTTP request into the
/// pending sync queue for later replay by [SyncWorker], then surfaces a Left so
/// the UI can show an error. The cache retains the last-known-good snapshot.
class LucentHealthContextRepository implements HealthContextRepository {
  LucentHealthContextRepository({
    required HealthContextRemoteDataSource dataSource,
    required HealthContextMapper mapper,
    required this.dao,
    this.pendingSyncDao,
    this.syncWorker,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final HealthContextRemoteDataSource _dataSource;
  final HealthContextMapper _mapper;
  final HealthContextDao dao;
  final PendingSyncDao? pendingSyncDao;
  final SyncWorker? syncWorker;

  DateTime? _lastRefreshAttempt;

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() {
    return TaskEither.tryCatch(() async {
      // 1. Check cache
      final cachedJson = await dao.fetch();
      if (cachedJson != null) {
        final cached = HealthContextSnapshotCodec.decode(cachedJson);
        // Background refresh (throttled) — best-effort cache write (path B).
        _refreshInBackground();
        return cached;
      }

      // 2. Cache empty → fetch from network. Populating the cache is part of
      // the request contract, so a cache write failure is a Left (path A).
      final dto = await _dataSource.fetchHealthContext();
      final snapshot = _mapper.fromDto(dto);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) {
    return _write(() => _dataSource.updateProfile(input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) {
    return _write(() => _dataSource.createAllergy(input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) {
    return _write(() => _dataSource.updateAllergy(id, input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id) {
    return _write(() => _dataSource.deleteAllergy(id));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) {
    return _write(() => _dataSource.createCondition(input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) {
    return _write(() => _dataSource.updateCondition(id, input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id) {
    return _write(() => _dataSource.deleteCondition(id));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) {
    return _write(() => _dataSource.createCurrentMedicine(input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) {
    return _write(() => _dataSource.updateCurrentMedicine(id, input));
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  ) {
    return _write(() => _dataSource.deleteCurrentMedicine(id));
  }

  /// Runs a remote write, replaces the cached snapshot on success, and maps
  /// every failure to a [LucentFailure] Left.
  ///
  /// Network failures ([DioException]) are first enqueued into the pending
  /// sync queue (existing contract), then surfaced as a Left. Any other
  /// failure (cache write included) is also a Left — the repository never
  /// turns a failed write into an unconditional success.
  TaskEither<LucentFailure, HealthContextSnapshot> _write(
    Future<HealthContextResponseDto> Function() remote,
  ) {
    return TaskEither.tryCatch(() async {
      try {
        final result = await remote();
        final snapshot = _mapper.fromDto(result);
        await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
        return snapshot;
      } on DioException catch (e) {
        await _enqueueWriteFailure(e);
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Enqueues a failed write operation into the pending sync queue.
  ///
  /// The HTTP method, path, and request body are serialized from the
  /// [DioException]'s [RequestOptions] so the [SyncWorker] can replay
  /// the exact same request when connectivity is restored.
  ///
  /// Enqueueing is best-effort: if the local DB write fails, the failure is
  /// only logged and the original network failure is still surfaced as a Left.
  Future<void> _enqueueWriteFailure(DioException e) async {
    appTalker.warning('HealthContext write failed, queuing for sync: $e');

    final psq = pendingSyncDao;
    if (psq == null) return;

    try {
      final requestOptions = e.requestOptions;
      await psq.enqueue(
        entityType: 'health_context',
        operation: 'write',
        payload: _serializeHttpRequest(requestOptions),
      );
      unawaited(syncWorker?.flush());
    } catch (error, stackTrace) {
      // 入队（本地 DB 写）失败不得掩盖原始网络失败：仅记录日志，仍按原
      // 网络失败映射 Left。
      appTalker.error(
        'HealthContext write enqueue failed, keeping the original network '
        'failure: $error',
        stackTrace,
      );
    }
  }

  /// Serializes a [RequestOptions] into a JSON string for the pending sync
  /// queue payload.
  static String _serializeHttpRequest(RequestOptions options) {
    final body = options.data;
    return jsonEncode({
      'method': options.method,
      'path': options.path,
      if (body is Map<String, dynamic>) 'body': body,
    });
  }

  void _refreshInBackground() {
    final now = DateTime.now();
    if (_lastRefreshAttempt != null &&
        now.difference(_lastRefreshAttempt!) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefreshAttempt = now;

    unawaited(
      Future(() async {
        try {
          final dto = await _dataSource.fetchHealthContext();
          final snapshot = _mapper.fromDto(dto);
          await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
        } catch (e) {
          // Best-effort background refresh (path B): the cached snapshot has
          // already been returned, so a refresh failure — network or cache
          // write — is only observed, never surfaced.
          appTalker.warning('HealthContext background refresh failed: $e');
        }
      }),
    );
  }
}
