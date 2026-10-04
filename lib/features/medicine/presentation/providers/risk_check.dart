import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'risk_check.g.dart';

/// Fetches the latest risk check records (static + llm) from the API.
/// Keep-alive so the result is cached across tab switches.
///
/// 关掉 riverpod 默认自动重试：默认策略是 10 次退避（约 40s），失败时要先干等
/// 骨架屏才会转错误态，而用户看到的只是"一直在转"。失败即转 `StateErrorView`，
/// 重试交给页面上的显式动作（与 `runMedicineRiskCheck` 同口径）。
@Riverpod(keepAlive: true, retry: _noRunRetry)
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

/// 命令型 provider 的失败必须立即进入 AsyncError,不走 riverpod 默认的指数退避
/// 自动重试:否则一次点击失败会被 ~40s 的静默重试掩盖(每次重试都会重新 POST 一次
/// 风险检查),调用方也要等重试耗尽才拿得到失败对象。手动重试 = 再次点击运行按钮。
Duration? _noRunRetry(int retryCount, Object error) => null;

/// Runs a risk check of the given [type].
/// Invalidates the records provider so the next read fetches fresh data.
@Riverpod(retry: _noRunRetry)
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
