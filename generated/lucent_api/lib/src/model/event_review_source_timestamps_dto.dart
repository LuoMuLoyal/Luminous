//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_source_timestamps_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewSourceTimestampsDto {
  /// Returns a new [EventReviewSourceTimestampsDto] instance.
  EventReviewSourceTimestampsDto({
    required this.checkIns,

    required this.dailyRecords,

    required this.doseLogs,
  });

  /// Last check-in calendar date (YYYY-MM-DD), or null.
  @JsonKey(name: r'checkIns', required: true, includeIfNull: true)
  final String? checkIns;

  /// Latest daily-record creation time in the event window (ISO 8601), or null.
  @JsonKey(name: r'dailyRecords', required: true, includeIfNull: true)
  final String? dailyRecords;

  /// Latest dose-log scheduled time in the event window (ISO 8601), or null.
  @JsonKey(name: r'doseLogs', required: true, includeIfNull: true)
  final String? doseLogs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewSourceTimestampsDto &&
          other.checkIns == checkIns &&
          other.dailyRecords == dailyRecords &&
          other.doseLogs == doseLogs;

  @override
  int get hashCode =>
      (checkIns == null ? 0 : checkIns.hashCode) +
      (dailyRecords == null ? 0 : dailyRecords.hashCode) +
      (doseLogs == null ? 0 : doseLogs.hashCode);

  factory EventReviewSourceTimestampsDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewSourceTimestampsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewSourceTimestampsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
