import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_sync_result.freezed.dart';

@freezed
abstract class HealthSyncResult with _$HealthSyncResult {
  const factory HealthSyncResult({
    required int successCount,
    required int skippedCount,
    required int failedCount,
    @Default([]) List<String> errors,
  }) = _HealthSyncResult;
}
