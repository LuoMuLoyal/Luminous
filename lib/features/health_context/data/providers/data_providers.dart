import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/health_context/data/datasources/remote_data_source.dart';
import 'package:luminous/features/health_context/data/mappers/mapper.dart';
import 'package:luminous/features/health_context/data/repositories/lucent_repository.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/repositories/repository.dart';

final healthContextMapperProvider = Provider<HealthContextMapper>(
  (ref) => HealthContextMapper(),
);

final healthContextRemoteDataSourceProvider =
    Provider<HealthContextRemoteDataSource>((ref) {
      final api = ref.watch(lucentUserHealthContextApiProvider);
      final dio = ref.watch(lucentDioClientProvider).dio;
      return HealthContextRemoteDataSource(api: api, dio: dio);
    });

final healthContextRepositoryProvider = Provider<HealthContextRepository>((
  ref,
) {
  final dataSource = ref.watch(healthContextRemoteDataSourceProvider);
  final mapper = ref.watch(healthContextMapperProvider);
  return LucentHealthContextRepository(dataSource: dataSource, mapper: mapper);
});

final healthContextSnapshotProvider = FutureProvider<HealthContextSnapshot>((
  ref,
) {
  final session = ref.watch(authSessionProvider);
  if (session.isLoading) {
    return pendingAuthSessionResolution();
  }
  if (!session.canAccessProtectedData) {
    throw const AuthRequiredException();
  }

  final repository = ref.watch(healthContextRepositoryProvider);
  return repository.fetchHealthContext().timeout(
    const Duration(seconds: 5),
    onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
  );
});
