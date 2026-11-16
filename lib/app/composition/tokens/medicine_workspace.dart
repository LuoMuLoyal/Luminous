import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/app/composition/tokens/medicine_style.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder/remote.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_workspace.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';
import 'package:luminous/features/medicine/domain/repositories/workspace.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'medicine_workspace.g.dart';

/// 药品工作区的组合根接线（仓储 + 提醒数据源）。
///
/// 仓储需要设计令牌（`tokens/medicine_style.dart`），而 `medicine/data/`
/// 不允许 import 组合根——所以装配落在这一处，由 `data/` 的 provider 文件
/// re-export [medicineWorkspaceRepositoryProvider]。
///
/// 这里同时定义提醒远端数据源：它原本在 `medicine/workspace.dart`，两个文件
/// 互相 export 会成环（arch_guard），合并到一处后两边都用得到。

@riverpod
MedicineReminderRemoteDataSource medicineReminderRemoteDataSource(Ref ref) {
  final api = ref.watch(lucentClientProvider).medicineReminders;
  final dio = ref.watch(lucentDioClientProvider).dio;
  return MedicineReminderRemoteDataSource(api: api, dio: dio);
}

/// Provider for [ReminderRepository] — returns the remote data source
/// which implements the domain interface.
@riverpod
ReminderRepository reminderRepository(Ref ref) {
  return ref.watch(medicineReminderRemoteDataSourceProvider);
}

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
