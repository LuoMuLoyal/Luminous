/// Marks one planned dose as `skipped`.
///
/// The medicine repository is described locally as [DoseLogMarkWriter] rather
/// than importing the medicine feature's `domain/repositories/`: the application
/// layer may only see its own feature's `domain/`, and the only shared value
/// here is the `doseLogs` data-change topic string.
///
/// Callers validate that the medicine id and date are present first; a failed
/// write throws and the UI decides how to surface it.
class SkipDoseUseCase {
  const SkipDoseUseCase({required this.writer, required this.emitDataChange});

  final DoseLogMarkWriter writer;

  /// Broadcasts a data-change topic (the `doseLogs` wire string).
  final void Function(String topic) emitDataChange;

  Future<void> call({
    required String currentMedicineId,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    await writer.mark(
      currentMedicineId: currentMedicineId,
      status: 'skipped',
      date: date,
      reminderId: reminderId,
      scheduledTime: scheduledTime,
    );
    emitDataChange(_doseLogsTopic);
  }

  /// The `DataChangeTopic.doseLogs` wire value; kept here so the use case names
  /// it without importing `core`.
  static const String _doseLogsTopic = 'doseLogs';
}

/// The dose-log write surface a skip needs.
abstract interface class DoseLogMarkWriter {
  /// Marks a dose log for one medicine; throws when the write fails.
  Future<void> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  });
}
