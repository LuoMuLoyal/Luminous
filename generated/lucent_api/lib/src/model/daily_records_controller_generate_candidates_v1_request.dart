//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_records_controller_generate_candidates_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordsControllerGenerateCandidatesV1Request {
  /// Returns a new [DailyRecordsControllerGenerateCandidatesV1Request] instance.
  DailyRecordsControllerGenerateCandidatesV1Request({
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
      other is DailyRecordsControllerGenerateCandidatesV1Request &&
          other.text == text &&
          other.occurredAt == occurredAt &&
          other.timezone == timezone;

  @override
  int get hashCode => text.hashCode + occurredAt.hashCode + timezone.hashCode;

  factory DailyRecordsControllerGenerateCandidatesV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordsControllerGenerateCandidatesV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordsControllerGenerateCandidatesV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
