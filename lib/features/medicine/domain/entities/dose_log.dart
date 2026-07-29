/// Dose log status enum.
enum DoseLogStatus { taken, skipped, missed, planned }

/// A single dose log entry returned by the medicine dose-log API.
class DoseLogItem {
  const DoseLogItem({
    required this.id,
    this.currentMedicineId,
    this.reminderId,
    required this.status,
    required this.scheduledFor,
    this.scheduledTime,
    this.doseText,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String? currentMedicineId;
  final String? reminderId;
  final DoseLogStatus status;
  final String scheduledFor;
  final String? scheduledTime;
  final String? doseText;
  final String? note;
  final String createdAt;
  final String updatedAt;
}
