//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_list_response_items_attachments.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordListResponseItems {
  /// Returns a new [DailyRecordListResponseItems] instance.
  DailyRecordListResponseItems({
    required this.id,

    required this.kind,

    required this.healthEventId,

    required this.occurredAt,

    required this.occurredTime,

    required this.title,

    required this.value,

    required this.unit,

    required this.note,

    required this.source_,

    required this.payload,

    required this.mealAnalysisStatus,

    required this.mealAnalysisCoverage,

    required this.mealAnalysisUpdatedAt,

    required this.mealAnalysisFailureReason,

    required this.mealShortDescription,

    required this.mealTopFoods,

    required this.attachments,

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
    unknownEnumValue:
        DailyRecordListResponseItemsKindEnum.unknownDefaultOpenApi,
  )
  final DailyRecordListResponseItemsKindEnum kind;

  /// Linked health event id.
  @JsonKey(name: r'healthEventId', required: true, includeIfNull: true)
  final String? healthEventId;

  /// Date in YYYY-MM-DD format.
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Time in HH:mm 24-hour format when available.
  @JsonKey(name: r'occurredTime', required: true, includeIfNull: true)
  final String? occurredTime;

  /// Short label.
  @JsonKey(name: r'title', required: true, includeIfNull: true)
  final String? title;

  /// Measured value.
  @JsonKey(name: r'value', required: true, includeIfNull: true)
  final String? value;

  /// Unit label.
  @JsonKey(name: r'unit', required: true, includeIfNull: true)
  final String? unit;

  /// Free-text note.
  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final String? note;

  /// Source.
  @JsonKey(name: r'source', required: true, includeIfNull: true)
  final String? source_;

  /// Structured payload for kind-specific data. For sleep: { startAt, endAt, durationMinutes, quality?, deepMinutes?, lightMinutes?, remMinutes? }. For vital: { vitalType, value, unit, secondaryValue?, secondaryUnit? }. For activity: { activityType, value, unit }.
  @JsonKey(name: r'payload', required: true, includeIfNull: true)
  final Map<String, Object>? payload;

  /// Meal analysis status for meal records.
  @JsonKey(name: r'mealAnalysisStatus', required: true, includeIfNull: true)
  final String? mealAnalysisStatus;

  /// Meal analysis coverage for meal records.
  @JsonKey(name: r'mealAnalysisCoverage', required: true, includeIfNull: true)
  final String? mealAnalysisCoverage;

  /// Meal analysis updated timestamp (ISO 8601).
  @JsonKey(name: r'mealAnalysisUpdatedAt', required: true, includeIfNull: true)
  final String? mealAnalysisUpdatedAt;

  /// Display-safe meal analysis failure reason.
  @JsonKey(
    name: r'mealAnalysisFailureReason',
    required: true,
    includeIfNull: true,
  )
  final String? mealAnalysisFailureReason;

  /// Short meal description for list reads.
  @JsonKey(name: r'mealShortDescription', required: true, includeIfNull: true)
  final String? mealShortDescription;

  /// Top recognized foods for list reads.
  @JsonKey(name: r'mealTopFoods', required: true, includeIfNull: false)
  final List<String> mealTopFoods;

  @JsonKey(name: r'attachments', required: true, includeIfNull: false)
  final List<DailyRecordListResponseItemsAttachments> attachments;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordListResponseItems &&
          other.id == id &&
          other.kind == kind &&
          other.healthEventId == healthEventId &&
          other.occurredAt == occurredAt &&
          other.occurredTime == occurredTime &&
          other.title == title &&
          other.value == value &&
          other.unit == unit &&
          other.note == note &&
          other.source_ == source_ &&
          other.payload == payload &&
          other.mealAnalysisStatus == mealAnalysisStatus &&
          other.mealAnalysisCoverage == mealAnalysisCoverage &&
          other.mealAnalysisUpdatedAt == mealAnalysisUpdatedAt &&
          other.mealAnalysisFailureReason == mealAnalysisFailureReason &&
          other.mealShortDescription == mealShortDescription &&
          other.mealTopFoods == mealTopFoods &&
          other.attachments == attachments &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      (healthEventId == null ? 0 : healthEventId.hashCode) +
      occurredAt.hashCode +
      (occurredTime == null ? 0 : occurredTime.hashCode) +
      (title == null ? 0 : title.hashCode) +
      (value == null ? 0 : value.hashCode) +
      (unit == null ? 0 : unit.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (source_ == null ? 0 : source_.hashCode) +
      (payload == null ? 0 : payload.hashCode) +
      (mealAnalysisStatus == null ? 0 : mealAnalysisStatus.hashCode) +
      (mealAnalysisCoverage == null ? 0 : mealAnalysisCoverage.hashCode) +
      (mealAnalysisUpdatedAt == null ? 0 : mealAnalysisUpdatedAt.hashCode) +
      (mealAnalysisFailureReason == null
          ? 0
          : mealAnalysisFailureReason.hashCode) +
      (mealShortDescription == null ? 0 : mealShortDescription.hashCode) +
      mealTopFoods.hashCode +
      attachments.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory DailyRecordListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordListResponseItemsKindEnum {
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'meal')
  meal(r'meal'),
  @JsonValue(r'vital')
  vital(r'vital'),
  @JsonValue(r'mood')
  mood(r'mood'),
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'activity')
  activity(r'activity'),
  @JsonValue(r'note')
  note(r'note'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DailyRecordListResponseItemsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
