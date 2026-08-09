//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_attachment_input_dto.dart';
import 'package:lucent_api/src/model/daily_record_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_daily_record_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateDailyRecordDto {
  /// Returns a new [UpdateDailyRecordDto] instance.
  UpdateDailyRecordDto({
    this.kind,
    this.occurredAt,
    this.occurredTime,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
    this.healthEventId,
    this.attachments,
  });

  @JsonKey(
    name: r'kind',
    required: false,
    includeIfNull: false,
    unknownEnumValue: DailyRecordKind.unknownDefaultOpenApi,
  )
  final DailyRecordKind? kind;

  /// Date in YYYY-MM-DD format.
  @JsonKey(name: r'occurredAt', required: false, includeIfNull: false)
  final String? occurredAt;

  /// Time in HH:mm 24-hour format. Use null to clear.
  @JsonKey(name: r'occurredTime', required: false, includeIfNull: false)
  final String? occurredTime;

  /// Short label. Use null to clear.
  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  /// Measured value. Use null to clear.
  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final String? value;

  /// Unit label. Use null to clear.
  @JsonKey(name: r'unit', required: false, includeIfNull: false)
  final String? unit;

  /// Free-text note. Use null to clear.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// Structured payload for kind-specific data. Use null to clear.
  @JsonKey(name: r'payload', required: false, includeIfNull: false)
  final Map<String, Object>? payload;

  /// Active health event association. Use null to clear.
  @JsonKey(name: r'healthEventId', required: false, includeIfNull: false)
  final String? healthEventId;

  /// Replacement attachment metadata list. Omit to keep existing attachments; send [] to clear.
  @JsonKey(name: r'attachments', required: false, includeIfNull: false)
  final List<DailyRecordAttachmentInputDto>? attachments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDailyRecordDto &&
          other.kind == kind &&
          other.occurredAt == occurredAt &&
          other.occurredTime == occurredTime &&
          other.title == title &&
          other.value == value &&
          other.unit == unit &&
          other.note == note &&
          other.payload == payload &&
          other.healthEventId == healthEventId &&
          other.attachments == attachments;

  @override
  int get hashCode =>
      kind.hashCode +
      occurredAt.hashCode +
      (occurredTime == null ? 0 : occurredTime.hashCode) +
      (title == null ? 0 : title.hashCode) +
      (value == null ? 0 : value.hashCode) +
      (unit == null ? 0 : unit.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (payload == null ? 0 : payload.hashCode) +
      (healthEventId == null ? 0 : healthEventId.hashCode) +
      attachments.hashCode;

  factory UpdateDailyRecordDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateDailyRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDailyRecordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
