import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/health_context/data/datasources/health_context_remote_data_source.dart';
import 'package:luminous/features/health_context/data/mappers/health_context_mapper.dart';
import 'package:luminous/features/health_context/data/repositories/lucent_health_context_repository.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';

final healthContextMapperProvider = Provider<HealthContextMapper>(
  (ref) => HealthContextMapper(),
);

final healthContextRemoteDataSourceProvider =
    Provider<HealthContextRemoteDataSource>((ref) {
  final api = ref.watch(lucentUserHealthContextApiProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;
  return HealthContextRemoteDataSource(api: api, dio: dio);
});

final healthContextRepositoryProvider = Provider<HealthContextRepository>((ref) {
  final dataSource = ref.watch(healthContextRemoteDataSourceProvider);
  final mapper = ref.watch(healthContextMapperProvider);
  return LucentHealthContextRepository(dataSource: dataSource, mapper: mapper);
});

final healthContextSnapshotProvider = FutureProvider<HealthContextSnapshot>(
  (ref) {
    final repository = ref.watch(healthContextRepositoryProvider);
    return repository.fetchHealthContext().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
    );
  },
);
