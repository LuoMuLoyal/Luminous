import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

final medicineWorkspaceProvider = FutureProvider<MedicineWorkspace>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () =>
        ref.watch(medicineWorkspaceRepositoryProvider).fetchWorkspace(),
    signedOutFallback: () =>
        ref.watch(medicineWorkspaceRepositoryProvider).signedOutWorkspace,
  );
});
