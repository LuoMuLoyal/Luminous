import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/services/red_flag_evaluator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'risk_check.g.dart';

@Riverpod(keepAlive: true)
Future<MedicineRiskCheckResult> medicineRiskCheck(Ref ref) {
  return authGuarded(
    ref: ref,
    fetch: () {
      final repository = ref.watch(medicineRiskCheckRepositoryProvider);
      return ref
          .watch(healthContextSnapshotProvider.future)
          .then(repository.fetchForSnapshot);
    },
  );
}

@Riverpod(keepAlive: true)
Future<List<RedFlagAlert>> redFlagAlerts(Ref ref) async {
  final result = await ref.watch(medicineRiskCheckProvider.future);
  final snapshot = await ref.watch(healthContextSnapshotProvider.future);
  const evaluator = RedFlagEvaluator();
  return evaluator.evaluate(snapshot: snapshot, result: result);
}
