import 'package:luminous/features/health_data/data/datasources/health_platform.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapper.dart';
import 'package:luminous/features/health_data/data/repositories/health_sync.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart'
    as domain;
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_sync.g.dart';

@riverpod
HealthPlatformDataSource healthPlatformDataSource(Ref ref) {
  return HealthPlatformDataSource();
}

@riverpod
HealthRecordMapper healthRecordMapper(Ref ref) {
  return const HealthRecordMapper();
}

@riverpod
domain.HealthSyncRepository healthSyncRepository(Ref ref) {
  return HealthSyncRepositoryImpl(
    dataSource: ref.watch(healthPlatformDataSourceProvider),
    mapper: ref.watch(healthRecordMapperProvider),
    dailyRecordRepo: ref.watch(dailyRecordRepositoryProvider),
  );
}
