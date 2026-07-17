import 'dart:async';

import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/health_context/data/datasources/snapshot.dart';
import 'package:luminous/features/health_context/data/mappers/mapper.dart';
import 'package:luminous/features/health_context/data/repositories/lucent.dart';
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
  return LucentHealthContextRepository(
    dataSource: dataSource,
    mapper: mapper,
    dao: dao,
  );
}

@Riverpod(keepAlive: true)
Future<HealthContextSnapshot> healthContextSnapshot(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(healthContextRepositoryProvider)
        .fetchHealthContext()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
        ),
  );
}
