//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_summary_response_summaries_latest_attachments.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_response_summaries_latest.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryResponseSummariesLatest {
  /// Returns a new [DailyRecordSummaryResponseSummariesLatest] instance.
  DailyRecordSummaryResponseSummariesLatest({
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

    required this.mealAnalysisUpdatedAt,

    required this.mealAnalysisFailureReason,

    required this.mealHeadline,

    required this.mealCalorieMin,

    required this.mealCalorieMax,

    required this.mealCalorieBucket,

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
        DailyRecordSummaryResponseSummariesLatestKindEnum.unknownDefaultOpenApi,
  )
  final DailyRecordSummaryResponseSummariesLatestKindEnum kind;

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

  /// Structured payload for kind-specific data. For sleep: { startedAt, endedAt, durationMinutes, sleepType?, quality?, deepMinutes?, lightMinutes?, remMinutes? }. For symptom: { symptom?: string, severity?: \"mild\"|\"moderate\"|\"severe\"|\"unknown\", customLabel?: string }. For vital: { vitalType, value, unit, secondaryValue?, secondaryUnit? }. For activity: { activityType, value, unit }. For meal (detail reads only): { mealAnalysis: { version, analysisStatus, analyzedAt, sourceRevision, model, promptVersion, locale, failureReason, calorieRange, dishes, items, facets } }.
  @JsonKey(name: r'payload', required: true, includeIfNull: true)
  final Map<String, Object>? payload;

  /// Meal analysis status: \"analyzing\", \"analyzed\", or \"analysis_failed\".
  @JsonKey(name: r'mealAnalysisStatus', required: true, includeIfNull: true)
  final String? mealAnalysisStatus;

  /// Meal analysis updated timestamp (ISO 8601).
  @JsonKey(name: r'mealAnalysisUpdatedAt', required: true, includeIfNull: true)
  final String? mealAnalysisUpdatedAt;

  /// Stable failure reason code (image_count_invalid, vision_unavailable, model_failed, model_timeout, invalid_output).
  @JsonKey(
    name: r'mealAnalysisFailureReason',
    required: true,
    includeIfNull: true,
  )
  final String? mealAnalysisFailureReason;

  /// Most important meal finding, for the list row.
  @JsonKey(name: r'mealHeadline', required: true, includeIfNull: true)
  final String? mealHeadline;

  /// Estimated energy interval lower bound (kcal).
  @JsonKey(name: r'mealCalorieMin', required: true, includeIfNull: true)
  final num? mealCalorieMin;

  /// Estimated energy interval upper bound (kcal).
  @JsonKey(name: r'mealCalorieMax', required: true, includeIfNull: true)
  final num? mealCalorieMax;

  /// Coarse energy bucket derived from the interval.
  @JsonKey(
    name: r'mealCalorieBucket',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        DailyRecordSummaryResponseSummariesLatestMealCalorieBucketEnum
            .unknownDefaultOpenApi,
  )
  final DailyRecordSummaryResponseSummariesLatestMealCalorieBucketEnum?
  mealCalorieBucket;

  @JsonKey(name: r'attachments', required: true, includeIfNull: false)
  final List<DailyRecordSummaryResponseSummariesLatestAttachments> attachments;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryResponseSummariesLatest &&
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
          other.mealAnalysisUpdatedAt == mealAnalysisUpdatedAt &&
          other.mealAnalysisFailureReason == mealAnalysisFailureReason &&
          other.mealHeadline == mealHeadline &&
          other.mealCalorieMin == mealCalorieMin &&
          other.mealCalorieMax == mealCalorieMax &&
          other.mealCalorieBucket == mealCalorieBucket &&
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
      (mealAnalysisUpdatedAt == null ? 0 : mealAnalysisUpdatedAt.hashCode) +
      (mealAnalysisFailureReason == null
          ? 0
          : mealAnalysisFailureReason.hashCode) +
      (mealHeadline == null ? 0 : mealHeadline.hashCode) +
      (mealCalorieMin == null ? 0 : mealCalorieMin.hashCode) +
      (mealCalorieMax == null ? 0 : mealCalorieMax.hashCode) +
      (mealCalorieBucket == null ? 0 : mealCalorieBucket.hashCode) +
      attachments.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory DailyRecordSummaryResponseSummariesLatest.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordSummaryResponseSummariesLatestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordSummaryResponseSummariesLatestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordSummaryResponseSummariesLatestKindEnum {
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

  const DailyRecordSummaryResponseSummariesLatestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Coarse energy bucket derived from the interval.
enum DailyRecordSummaryResponseSummariesLatestMealCalorieBucketEnum {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DailyRecordSummaryResponseSummariesLatestMealCalorieBucketEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
