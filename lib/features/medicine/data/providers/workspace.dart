import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_workspace.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workspace.g.dart';

@riverpod
MedicineReminderRemoteDataSource medicineReminderRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).medicineReminders;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return MedicineReminderRemoteDataSource(api: api, dio: dio);
}

@riverpod
MedicineWorkspaceRepository medicineWorkspaceRepository(Ref ref) {
  final healthRepo = ref.watch(healthContextRepositoryProvider);
  final doseLogDs = ref.watch(doseLogRemoteDataSourceProvider);
  final reminderDs = ref.watch(medicineReminderRemoteDataSourceProvider);
  final riskCheckRepository = ref.watch(medicineRiskCheckRepositoryProvider);
  return LucentMedicineWorkspaceRepository(
    healthRepo: healthRepo,
    doseLogDs: doseLogDs,
    reminderDs: reminderDs,
    riskCheckRepository: riskCheckRepository,
  );
}
