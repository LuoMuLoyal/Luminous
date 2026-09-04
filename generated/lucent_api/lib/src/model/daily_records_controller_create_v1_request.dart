//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_records_controller_create_v1_request_attachments_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_records_controller_create_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordsControllerCreateV1Request {
  /// Returns a new [DailyRecordsControllerCreateV1Request] instance.
  DailyRecordsControllerCreateV1Request({
    required this.kind,

    required this.occurredAt,

    this.occurredTime,

    this.title,

    this.value,

    this.unit,

    this.note,

    this.source_,

    this.healthEventId,

    this.payload,

    this.attachments,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        DailyRecordsControllerCreateV1RequestKindEnum.unknownDefaultOpenApi,
  )
  final DailyRecordsControllerCreateV1RequestKindEnum kind;

  /// Date in YYYY-MM-DD format. For sleep records this is the wake date (the morning the user wakes up from that sleep).
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Time in HH:mm 24-hour format. When omitted, UI flows may treat the record as date-only.
  @JsonKey(name: r'occurredTime', required: false, includeIfNull: false)
  final String? occurredTime;

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

  /// Record source. Defaults to \"manual\". Use \"apple_health\" or \"health_connect\" for auto-synced records.
  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  /// Optional active health event association.
  @JsonKey(name: r'healthEventId', required: false, includeIfNull: false)
  final String? healthEventId;

  /// Structured payload for kind-specific data. For sleep: { sleepType?: \"nightSleep\"|\"nap\", startedAt?: string, endedAt?: string, durationMinutes, quality? }. Legacy startAt/endAt remain readable and map to nightSleep. endedAt must be later than startedAt; cross-midnight intervals are valid. For vital: { vitalType: \"heartRate\"|\"bloodPressure\"|\"bloodOxygen\"|\"bloodGlucose\"|\"bodyTemperature\"|\"weight\"|\"respiratoryRate\", value: number, unit: string, secondaryValue?: number, secondaryUnit?: string }. For activity: { activityType: \"steps\"|\"flightsClimbed\"|\"distance\"|\"exerciseTime\", value: number, unit: string }. Vital and activity payloads are optional for manual entry.
  @JsonKey(name: r'payload', required: false, includeIfNull: false)
  final Map<String, Object>? payload;

  /// Attachment metadata. File upload itself is handled separately.
  @JsonKey(name: r'attachments', required: false, includeIfNull: false)
  final List<DailyRecordsControllerCreateV1RequestAttachmentsInner>?
  attachments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordsControllerCreateV1Request &&
          other.kind == kind &&
          other.occurredAt == occurredAt &&
          other.occurredTime == occurredTime &&
          other.title == title &&
          other.value == value &&
          other.unit == unit &&
          other.note == note &&
          other.source_ == source_ &&
          other.healthEventId == healthEventId &&
          other.payload == payload &&
          other.attachments == attachments;

  @override
  int get hashCode =>
      kind.hashCode +
      occurredAt.hashCode +
      occurredTime.hashCode +
      title.hashCode +
      value.hashCode +
      unit.hashCode +
      note.hashCode +
      source_.hashCode +
      (healthEventId == null ? 0 : healthEventId.hashCode) +
      payload.hashCode +
      attachments.hashCode;

  factory DailyRecordsControllerCreateV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordsControllerCreateV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordsControllerCreateV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordsControllerCreateV1RequestKindEnum {
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

  const DailyRecordsControllerCreateV1RequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
