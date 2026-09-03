//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_deliveries_controller_record_receipt_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveriesControllerRecordReceiptV1Request {
  /// Returns a new [ReminderDeliveriesControllerRecordReceiptV1Request] instance.
  ReminderDeliveriesControllerRecordReceiptV1Request({
    required this.reminderId,

    required this.scheduledDate,

    required this.scheduledTime,
  });

  /// Linked medicine reminder id.
  @JsonKey(name: r'reminderId', required: true, includeIfNull: false)
  final String reminderId;

  /// Local scheduled date in YYYY-MM-DD format.
  @JsonKey(name: r'scheduledDate', required: true, includeIfNull: false)
  final String scheduledDate;

  /// Local scheduled time in HH:mm format (24h).
  @JsonKey(name: r'scheduledTime', required: true, includeIfNull: false)
  final String scheduledTime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveriesControllerRecordReceiptV1Request &&
          other.reminderId == reminderId &&
          other.scheduledDate == scheduledDate &&
          other.scheduledTime == scheduledTime;

  @override
  int get hashCode =>
      reminderId.hashCode + scheduledDate.hashCode + scheduledTime.hashCode;

  factory ReminderDeliveriesControllerRecordReceiptV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$ReminderDeliveriesControllerRecordReceiptV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveriesControllerRecordReceiptV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
