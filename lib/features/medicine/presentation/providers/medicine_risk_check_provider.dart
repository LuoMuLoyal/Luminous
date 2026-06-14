import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/medicine/data/repositories/medicine_risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';

final medicineRiskCheckProvider = FutureProvider<MedicineRiskCheckResult>((ref) {
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
