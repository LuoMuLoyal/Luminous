import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/health_context.dart';
import 'package:luminous/features/health_context/data/repositories/lucent.dart';
import 'package:luminous/features/health_context/data/utils/health_context_snapshot_codec.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      appTalker.warning('HealthContext sync replay: cache refresh failed: $e');
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

@Riverpod(keepAlive: true)
Future<HealthContextSnapshot> healthContextSnapshot(Ref ref) {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthContext));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.currentMedicines));

  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(healthContextRepositoryProvider)
          .fetchHealthContext()
          .run()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
          );
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      return result.fold((failure) => throw failure, (snapshot) => snapshot);
    },
  );
}
