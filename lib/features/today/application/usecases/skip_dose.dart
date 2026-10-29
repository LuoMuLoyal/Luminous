import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';

/// Marks one planned dose as `skipped`.
///
/// Pure: the medicine domain's [DoseLogRepository] is a published cross-feature
/// domain interface (AGENTS.md §Cross-Feature Import Rules), so it arrives as a
/// plain argument — no `WidgetRef`, no data layer. The data-change broadcast is
/// injected the same way.
///
/// Callers validate that the medicine id and date are present first; a failed
/// write throws and the UI decides how to surface it.
class SkipDoseUseCase {
  const SkipDoseUseCase({
    required this.repository,
    required this.emitDataChange,
  });

  final DoseLogRepository repository;

  /// Broadcasts a data-change topic (the `doseLogs` wire string).
  final void Function(String topic) emitDataChange;

  Future<void> call({
    required String currentMedicineId,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    final result = await repository
        .mark(
          currentMedicineId: currentMedicineId,
          status: 'skipped',
          date: date,
          reminderId: reminderId,
          scheduledTime: scheduledTime,
        )
        .run();
    result.fold((failure) => throw failure, (_) {});
    emitDataChange(_doseLogsTopic);
  }

  /// The `DataChangeTopic.doseLogs` wire value; kept here so the use case names
  /// it without importing `core`.
  static const String _doseLogsTopic = 'doseLogs';
}
