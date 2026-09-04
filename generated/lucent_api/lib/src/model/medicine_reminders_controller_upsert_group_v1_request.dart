//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_reminders_controller_upsert_group_v1_request_slots_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminders_controller_upsert_group_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRemindersControllerUpsertGroupV1Request {
  /// Returns a new [MedicineRemindersControllerUpsertGroupV1Request] instance.
  MedicineRemindersControllerUpsertGroupV1Request({
    required this.currentMedicineId,

    this.label,

    this.daysOfWeek,

    this.startDate,

    this.endDate,

    this.isActive,

    this.note,

    required this.slots,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: true, includeIfNull: false)
  final String currentMedicineId;

  /// Reminder label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  /// Weekday numbers 0-6, where null means every day.
  @JsonKey(name: r'daysOfWeek', required: false, includeIfNull: false)
  final List<int>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts.
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final String? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final String? endDate;

  /// Whether this reminder is active.
  @JsonKey(name: r'isActive', required: false, includeIfNull: false)
  final bool? isActive;

  /// User note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// Reminder slots for this medicine. Replaces the whole group.
  @JsonKey(name: r'slots', required: true, includeIfNull: false)
  final List<MedicineRemindersControllerUpsertGroupV1RequestSlotsInner> slots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRemindersControllerUpsertGroupV1Request &&
          other.currentMedicineId == currentMedicineId &&
          other.label == label &&
          other.daysOfWeek == daysOfWeek &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive &&
          other.note == note &&
          other.slots == slots;

  @override
  int get hashCode =>
      currentMedicineId.hashCode +
      (label == null ? 0 : label.hashCode) +
      (daysOfWeek == null ? 0 : daysOfWeek.hashCode) +
      (startDate == null ? 0 : startDate.hashCode) +
      (endDate == null ? 0 : endDate.hashCode) +
      isActive.hashCode +
      (note == null ? 0 : note.hashCode) +
      slots.hashCode;

  factory MedicineRemindersControllerUpsertGroupV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRemindersControllerUpsertGroupV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRemindersControllerUpsertGroupV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
