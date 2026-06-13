//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_attachment_input_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_daily_record_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDailyRecordDto {
  /// Returns a new [CreateDailyRecordDto] instance.
  CreateDailyRecordDto({
    required this.kind,

    required this.occurredAt,

    this.title,

    this.value,

    this.unit,

    this.note,

    this.payload,

    this.attachments,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DailyRecordKind.unknownDefaultOpenApi,
  )
  final DailyRecordKind kind;

  /// Date in YYYY-MM-DD format.
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Short label.
  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  /// Measured value.
  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final String? value;

  /// Unit label.
  @JsonKey(name: r'unit', required: false, includeIfNull: false)
  final String? unit;

  /// Free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// Structured payload for kind-specific data. For sleep: { startAt, endAt, durationMinutes, quality? }.
  @JsonKey(name: r'payload', required: false, includeIfNull: false)
  final Object? payload;

  /// Attachment metadata. File upload itself is handled separately.
  @JsonKey(name: r'attachments', required: false, includeIfNull: false)
  final List<DailyRecordAttachmentInputDto>? attachments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDailyRecordDto &&
          other.kind == kind &&
          other.occurredAt == occurredAt &&
          other.title == title &&
          other.value == value &&
          other.unit == unit &&
          other.note == note &&
          other.payload == payload &&
          other.attachments == attachments;

  @override
  int get hashCode =>
      kind.hashCode +
      occurredAt.hashCode +
      title.hashCode +
      value.hashCode +
      unit.hashCode +
      note.hashCode +
      payload.hashCode +
      attachments.hashCode;

  factory CreateDailyRecordDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDailyRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDailyRecordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
