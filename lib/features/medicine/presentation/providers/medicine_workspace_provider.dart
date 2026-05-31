import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';

final medicineWorkspaceProvider = FutureProvider<MedicineWorkspace>((ref) {
  return ref.watch(medicineWorkspaceRepositoryProvider).fetchWorkspace();
});
