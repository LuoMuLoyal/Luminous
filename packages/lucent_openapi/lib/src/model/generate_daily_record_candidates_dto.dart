//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'generate_daily_record_candidates_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateDailyRecordCandidatesDto {
  /// Returns a new [GenerateDailyRecordCandidatesDto] instance.
  GenerateDailyRecordCandidatesDto({
    required this.text,

    required this.occurredAt,

    this.timezone,
  });

  /// Natural-language note to be parsed into candidate daily records.
  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  /// Wake date in YYYY-MM-DD format used as the candidate record date baseline.
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Optional user timezone hint used only for interpretation wording. No server timezone conversion is persisted.
  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateDailyRecordCandidatesDto &&
          other.text == text &&
          other.occurredAt == occurredAt &&
          other.timezone == timezone;

  @override
  int get hashCode => text.hashCode + occurredAt.hashCode + timezone.hashCode;

  factory GenerateDailyRecordCandidatesDto.fromJson(
    Map<String, dynamic> json,
  ) => _$GenerateDailyRecordCandidatesDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GenerateDailyRecordCandidatesDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
