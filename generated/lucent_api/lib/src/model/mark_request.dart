//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mark_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MarkRequest {
  /// Returns a new [MarkRequest] instance.
  MarkRequest({
    this.currentMedicineId,

    this.reminderId,

    this.healthEventId,

    required this.status,

    required this.scheduledFor,

    this.scheduledTime,

    this.doseText,

    this.note,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final String? currentMedicineId;

  /// Linked reminder id for slot-aware marks.
  @JsonKey(name: r'reminderId', required: false, includeIfNull: false)
  final String? reminderId;

  /// Linked active health event id.
  @JsonKey(name: r'healthEventId', required: false, includeIfNull: false)
  final String? healthEventId;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MarkRequestStatusEnum.unknownDefaultOpenApi,
  )
  final MarkRequestStatusEnum status;

  /// Scheduled date YYYY-MM-DD.
  @JsonKey(name: r'scheduledFor', required: true, includeIfNull: false)
  final String scheduledFor;

  /// Scheduled slot time in HH:mm for slot-aware marks.
  @JsonKey(name: r'scheduledTime', required: false, includeIfNull: false)
  final String? scheduledTime;

  /// Dose text.
  @JsonKey(name: r'doseText', required: false, includeIfNull: false)
  final String? doseText;

  /// Free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkRequest &&
          other.currentMedicineId == currentMedicineId &&
          other.reminderId == reminderId &&
          other.healthEventId == healthEventId &&
          other.status == status &&
          other.scheduledFor == scheduledFor &&
          other.scheduledTime == scheduledTime &&
          other.doseText == doseText &&
          other.note == note;

  @override
  int get hashCode =>
      currentMedicineId.hashCode +
      reminderId.hashCode +
      (healthEventId == null ? 0 : healthEventId.hashCode) +
      status.hashCode +
      scheduledFor.hashCode +
      scheduledTime.hashCode +
      (doseText == null ? 0 : doseText.hashCode) +
      (note == null ? 0 : note.hashCode);

  factory MarkRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MarkRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MarkRequestStatusEnum {
  @JsonValue(r'taken')
  taken(r'taken'),
  @JsonValue(r'skipped')
  skipped(r'skipped'),
  @JsonValue(r'missed')
  missed(r'missed'),
  @JsonValue(r'planned')
  planned(r'planned'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MarkRequestStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
