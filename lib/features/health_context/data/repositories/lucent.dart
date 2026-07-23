// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/daos/health_context_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/sync_worker.dart';
import 'package:luminous/core/logger/logger.dart';
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
/// If cache is empty, fetches from network and populates cache.
///
/// Write: attempts remote mutation; on success, replaces the cached snapshot.
/// On network failure ([DioException]), enqueues the HTTP request into the
/// pending sync queue for later replay by [SyncWorker], then rethrows so the
/// UI can show an error. The cache retains the last-known-good snapshot.
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
  Future<HealthContextSnapshot> fetchHealthContext() async {
    // 1. Check cache
    final cachedJson = await dao.fetch();
    if (cachedJson != null) {
      final cached = HealthContextSnapshotCodec.decode(cachedJson);
      // Background refresh (throttled)
      _refreshInBackground();
      return cached;
    }

    // 2. Cache empty → fetch from network
    final dto = await _dataSource.fetchHealthContext();
    final snapshot = _mapper.fromDto(dto);
    await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
    return snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    try {
      final result = await _dataSource.updateProfile(input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    try {
      final result = await _dataSource.createAllergy(input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    try {
      final result = await _dataSource.updateAllergy(id, input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    try {
      final result = await _dataSource.deleteAllergy(id);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    try {
      final result = await _dataSource.createCondition(input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    try {
      final result = await _dataSource.updateCondition(id, input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    try {
      final result = await _dataSource.deleteCondition(id);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    try {
      final result = await _dataSource.createCurrentMedicine(input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    try {
      final result = await _dataSource.updateCurrentMedicine(id, input);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    try {
      final result = await _dataSource.deleteCurrentMedicine(id);
      final snapshot = _mapper.fromDto(result);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
      return snapshot;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  /// Enqueues a failed write operation into the pending sync queue.
  ///
  /// The HTTP method, path, and request body are serialized from the
  /// [DioException]'s [RequestOptions] so the [SyncWorker] can replay
  /// the exact same request when connectivity is restored.
  Future<void> _enqueueWriteFailure(DioException e) async {
    appTalker.warning('HealthContext write failed, queuing for sync: $e');

    final psq = pendingSyncDao;
    if (psq == null) return;

    final requestOptions = e.requestOptions;
    await psq.enqueue(
      entityType: 'health_context',
      operation: 'write',
      payload: _serializeHttpRequest(requestOptions),
    );
    unawaited(syncWorker?.flush());
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
          appTalker.warning('HealthContext background refresh failed: $e');
        }
      }),
    );
  }
}
