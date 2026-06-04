//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_item_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordItemDto {
  /// Returns a new [DailyRecordItemDto] instance.
  DailyRecordItemDto({
    required this.id,

    required this.kind,

    required this.occurredAt,

    this.title,

    this.value,

    this.unit,

    this.note,

    this.source_,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Record id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

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
  final Object? title;

  /// Measured value.
  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final Object? value;

  /// Unit label.
  @JsonKey(name: r'unit', required: false, includeIfNull: false)
  final Object? unit;

  /// Free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  /// Source.
  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final Object? source_;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordItemDto &&
          other.id == id &&
          other.kind == kind &&
          other.occurredAt == occurredAt &&
          other.title == title &&
          other.value == value &&
          other.unit == unit &&
          other.note == note &&
          other.source_ == source_ &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      occurredAt.hashCode +
      title.hashCode +
      value.hashCode +
      unit.hashCode +
      note.hashCode +
      source_.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory DailyRecordItemDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
