import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart'
    show doseLogRepositoryProvider;
import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';

/// Skips a single planned dose by marking it as `skipped`.
///
/// This use case orchestrates the medicine-domain [DoseLogRepository] and
/// emits a [DataChangeTopic.doseLogs] event so today/medicine dashboards refresh.
///
/// Caller is responsible for validating that [currentMedicineId] and [date]
/// are present before invoking this use case. On failure the original exception
/// is rethrown and the UI decides how to surface it.
class SkipDoseUseCase {
  const SkipDoseUseCase({required this.ref});

  final WidgetRef ref;

  Future<void> call({
    required String currentMedicineId,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    final result = await ref
        .read(doseLogRepositoryProvider)
        .mark(
          currentMedicineId: currentMedicineId,
          status: 'skipped',
          date: date,
          reminderId: reminderId,
          scheduledTime: scheduledTime,
        )
        .run();
    result.fold((failure) => throw failure, (_) {});
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.doseLogs);
  }
}
