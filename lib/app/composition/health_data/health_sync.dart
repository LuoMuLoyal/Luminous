import 'package:luminous/features/health_data/data/datasources/health_platform.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// `healthSyncRepositoryProvider` is composed in
/// `lib/app/composition/health_sync/` (it needs `core/native` and the record
/// feature's data layer) and re-exported here so consumers keep importing
/// this file.
export 'package:luminous/app/composition/health_sync/health_sync.dart'
    show healthSyncRepositoryProvider;

part 'health_sync.g.dart';

/// Data-layer providers for health sync.

@riverpod
HealthPlatformDataSource healthPlatformDataSource(Ref ref) {
  return HealthPlatformDataSource();
}

@riverpod
HealthRecordMapper healthRecordMapper(Ref ref) {
  return const HealthRecordMapper();
}
