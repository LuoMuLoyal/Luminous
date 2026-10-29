import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/providers/session/auth_guarded.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/health_context.dart';
import 'package:luminous/features/health_context/data/repositories/lucent.dart';
import 'package:luminous/features/health_context/data/utils/health_context_snapshot_codec.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
export 'package:luminous/app/composition/health_context.dart'
    show healthContextSnapshotProvider;
part 'health_context.g.dart';

@riverpod
HealthContextMapper healthContextMapper(Ref ref) {
  return HealthContextMapper();
}

@riverpod
HealthContextRemoteDataSource healthContextRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).userHealthContext;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return HealthContextRemoteDataSource(api: api, dio: dio);
}

@riverpod
HealthContextRepository healthContextRepository(Ref ref) {
  final dataSource = ref.watch(healthContextRemoteDataSourceProvider);
  final mapper = ref.watch(healthContextMapperProvider);
  final dao = ref.watch(healthContextDaoProvider);
  final pendingSyncDao = ref.watch(pendingSyncDaoProvider);
  final syncWorker = ref.watch(syncWorkerProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  // Register replay handler for health_context entity type.
  // Replays the original HTTP request, then refreshes the cache by
  // fetching the full snapshot from the network.
  syncWorker.registerHandler('health_context', (entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    final method = payload['method'] as String;
    final path = payload['path'] as String;
    final body = payload['body'] as Map<String, dynamic>?;
    await dio.request<Object>(
      path,
      data: body,
      options: Options(method: method, contentType: Headers.jsonContentType),
    );
    // After successful replay, refresh the cache.
    try {
      final dto = await dataSource.fetchHealthContext();
      final snapshot = mapper.fromDto(dto);
      await dao.replace(HealthContextSnapshotCodec.encode(snapshot));
    } catch (e) {
      appLog.warning('HealthContext sync replay: cache refresh failed: $e');
    }
  });
  return LucentHealthContextRepository(
    dataSource: dataSource,
    mapper: mapper,
    dao: dao,
    pendingSyncDao: pendingSyncDao,
    syncWorker: syncWorker,
  );
}
