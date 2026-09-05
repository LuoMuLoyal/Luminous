//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_candidate_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_candidate_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordCandidateResponse {
  /// Returns a new [DailyRecordCandidateResponse] instance.
  DailyRecordCandidateResponse({
    required this.locale,

    required this.generatedAt,

    required this.confirmationHint,

    required this.items,
  });

  /// Normalized parse locale.
  @JsonKey(name: r'locale', required: true, includeIfNull: false)
  final String locale;

  /// ISO-8601 timestamp when candidates were generated.
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// Short UI hint telling the client that these are candidates, not saved records.
  @JsonKey(name: r'confirmationHint', required: true, includeIfNull: false)
  final String confirmationHint;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DailyRecordCandidateResponseItems> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordCandidateResponse &&
          other.locale == locale &&
          other.generatedAt == generatedAt &&
          other.confirmationHint == confirmationHint &&
          other.items == items;

  @override
  int get hashCode =>
      locale.hashCode +
      generatedAt.hashCode +
      confirmationHint.hashCode +
      items.hashCode;

  factory DailyRecordCandidateResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordCandidateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordCandidateResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
