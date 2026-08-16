/// Dose log status enum.
enum DoseLogStatus {
  taken,
  skipped,
  // TODO(archive): 历史兼容值，主路径不写入；漏服语义由后端 overdueUnconfirmed
  // 派生，未来若落漏服标记应在后端 collector 侧产出，前端保持消费方。
  missed,
  planned,
}

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
