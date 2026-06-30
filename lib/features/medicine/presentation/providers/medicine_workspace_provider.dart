import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';

final medicineWorkspaceProvider = FutureProvider<MedicineWorkspace>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session.isConfirmedSignedOut) {
    if (kDebugMode) {
      return Future.value(MockMedicineWorkspaceRepository.signedOutWorkspace);
    }
    return Future.value(MedicineWorkspace.signedOut());
  }
  if (!session.canAccessProtectedData) {
    return pendingAuthSessionResolution();
  }

  return ref.watch(medicineWorkspaceRepositoryProvider).fetchWorkspace();
});
