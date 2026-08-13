//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_check_in_coverage_dto.dart';
import 'package:lucent_api/src/model/event_review_observed_source_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_coverage_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewCoverageSummaryDto {
  /// Returns a new [EventReviewCoverageSummaryDto] instance.
  EventReviewCoverageSummaryDto({
    required this.checkIns,

    required this.dailyRecords,

    required this.doseLogs,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: false)
  final EventReviewCheckInCoverageDto checkIns;

  @JsonKey(name: r'dailyRecords', required: true, includeIfNull: false)
  final EventReviewObservedSourceDto dailyRecords;

  @JsonKey(name: r'doseLogs', required: true, includeIfNull: false)
  final EventReviewObservedSourceDto doseLogs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewCoverageSummaryDto &&
          other.checkIns == checkIns &&
          other.dailyRecords == dailyRecords &&
          other.doseLogs == doseLogs;

  @override
  int get hashCode =>
      checkIns.hashCode + dailyRecords.hashCode + doseLogs.hashCode;

  factory EventReviewCoverageSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewCoverageSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewCoverageSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
