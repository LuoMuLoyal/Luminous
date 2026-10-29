import 'package:luminous/app/composition/health_data/health_sync.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/core/native/bridge.dart';
import 'package:luminous/features/health_data/data/datasources/steps.dart';
import 'package:luminous/features/health_data/data/repositories/health_sync.dart';
import 'package:luminous/features/health_data/domain/repositories/health_sync.dart'
    as domain;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_sync.g.dart';

/// Composition-root glue for health sync.
///
/// These providers need `core/native` (the platform bridge) and the record
/// feature's daily-record repository, neither of which `health_data/data/`
/// may import. The data provider file re-exports them.

@riverpod
NativeStepSource? nativeStepSource(Ref ref) {
  if (!ref.watch(nativeStepsEnabledProvider)) return null;
  return NativeStepSource(bridge: ref.watch(nativeBridgeProvider).steps);
}

@riverpod
domain.HealthSyncRepository healthSyncRepository(Ref ref) {
  return HealthSyncRepositoryImpl(
    dataSource: ref.watch(healthPlatformDataSourceProvider),
    mapper: ref.watch(healthRecordMapperProvider),
    dailyRecordRepo: ref.watch(dailyRecordRepositoryProvider),
    nativeStepSource: ref.watch(nativeStepSourceProvider),
  );
}
