import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/app/composition/medicine/workspace.dart';
import 'package:luminous/app/composition/tokens/medicine_style.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_workspace.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'medicine_workspace.g.dart';

/// Composition-root glue for the medicine workspace.
///
/// The repository needs the workspace design tokens (`app/composition/
/// medicine_style.dart`), which `medicine/data/` may not import. The data
/// provider file re-exports [medicineWorkspaceRepositoryProvider].

@riverpod
MedicineWorkspaceRepository medicineWorkspaceRepository(Ref ref) {
  final healthRepo = ref.watch(healthContextRepositoryProvider);
  final doseLogDs = ref.watch(doseLogRemoteDataSourceProvider);
  final reminderDs = ref.watch(medicineReminderRemoteDataSourceProvider);
  final riskCheckRepository = ref.watch(medicineRiskCheckRepositoryProvider);
  final workspaceDao = ref.watch(medicineWorkspaceDaoProvider);
  return LucentMedicineWorkspaceRepository(
    healthRepo: healthRepo,
    doseLogDs: doseLogDs,
    reminderDs: reminderDs,
    riskCheckRepository: riskCheckRepository,
    workspaceDao: workspaceDao,
    style: const MedicineWorkspaceStyle(),
  );
}
