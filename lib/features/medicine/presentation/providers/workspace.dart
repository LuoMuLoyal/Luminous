import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workspace.g.dart';

@Riverpod(keepAlive: true)
Future<MedicineWorkspace> medicineWorkspace(Ref ref) {
  // Watch cross-feature data change topics.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.currentMedicines));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.doseLogs));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.medicineReminders));

  return authGuarded(
    ref: ref,
    fetch: () async {
      // Left 投影到 AsyncValue.error：widget 只消费 provider state。
      final result = await ref
          .watch(medicineWorkspaceRepositoryProvider)
          .fetchWorkspace()
          .run();
      return result.fold((failure) => throw failure, (workspace) => workspace);
    },
    signedOutFallback: () =>
        ref.watch(medicineWorkspaceRepositoryProvider).signedOutWorkspace,
  );
}
