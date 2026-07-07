import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/health_context/data/providers/data_providers.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/services/red_flag_evaluator.dart';

final medicineRiskCheckProvider = FutureProvider<MedicineRiskCheckResult>((
  ref,
) {
  final session = ref.watch(authSessionProvider);
  if (!session.canAccessProtectedData) {
    if (session.isLoading) {
      return pendingAuthSessionResolution();
    }
    throw const AuthRequiredException();
  }

  final repository = ref.watch(medicineRiskCheckRepositoryProvider);
  return ref
      .watch(healthContextSnapshotProvider.future)
      .then(repository.fetchForSnapshot);
});

final redFlagAlertsProvider = FutureProvider<List<RedFlagAlert>>((ref) async {
  final result = await ref.watch(medicineRiskCheckProvider.future);
  final snapshot = await ref.watch(healthContextSnapshotProvider.future);
  const evaluator = RedFlagEvaluator();
  return evaluator.evaluate(snapshot: snapshot, result: result);
});
