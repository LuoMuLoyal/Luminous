import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'risk_check.g.dart';

/// Fetches the latest risk check records (static + llm) from the API.
/// Keep-alive so the result is cached across tab switches.
@Riverpod(keepAlive: true)
Future<MedicineRiskCheckRecords> medicineRiskCheckRecords(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () async {
      final repository = ref.watch(medicineRiskCheckRepositoryProvider);
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      final result = await repository.getRecords().run();
      return result.fold((failure) => throw failure, (records) => records);
    },
  );
}

/// Convenience provider that extracts the best available record
/// (LLM preferred, fallback to static, null if never checked).
@Riverpod(keepAlive: true)
Future<MedicineRiskCheckRecord?> medicineRiskCheckBestRecord(Ref ref) async {
  final records = await ref.watch(medicineRiskCheckRecordsProvider.future);
  return records.bestRecord;
}

/// Convenience provider that extracts the result from the best record.
@Riverpod(keepAlive: true)
Future<MedicineRiskCheckResult> medicineRiskCheck(Ref ref) async {
  final record = await ref.watch(medicineRiskCheckBestRecordProvider.future);
  return record?.result ?? const MedicineRiskCheckResult();
}

/// Convenience provider that extracts red flags from the best record.
@Riverpod(keepAlive: true)
Future<List<RedFlagAlert>> redFlagAlerts(Ref ref) async {
  final result = await ref.watch(medicineRiskCheckProvider.future);
  return result.redFlags;
}

/// Runs a risk check of the given [type].
/// Invalidates the records provider so the next read fetches fresh data.
@riverpod
Future<MedicineRiskCheckRecord> runMedicineRiskCheck(
  Ref ref,
  MedicineRiskCheckType type,
) {
  return authGuarded(
    ref: ref,
    fetch: () async {
      final repository = ref.watch(medicineRiskCheckRepositoryProvider);
      // Left 投影到 AsyncValue.error：页面 catch 既有逻辑不变。
      final result = await repository.runCheck(type).run();
      final record = result.fold((failure) => throw failure, (value) => value);
      // Invalidate cached records so next read sees the fresh record.
      ref.invalidate(medicineRiskCheckRecordsProvider);
      return record;
    },
  );
}
