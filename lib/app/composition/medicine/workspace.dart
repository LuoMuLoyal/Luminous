import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:luminous/app/composition/tokens/medicine_workspace.dart'
    show medicineWorkspaceRepositoryProvider;

part 'workspace.g.dart';

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
