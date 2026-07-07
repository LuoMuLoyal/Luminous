import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/medicine/data/repositories/mock_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

final medicineWorkspaceProvider = FutureProvider<MedicineWorkspace>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session.isConfirmedSignedOut) {
    return Future.value(MockMedicineWorkspaceRepository.previewWorkspace);
  }
  if (!session.canAccessProtectedData) {
    return pendingAuthSessionResolution();
  }

  return ref.watch(medicineWorkspaceRepositoryProvider).fetchWorkspace();
});
