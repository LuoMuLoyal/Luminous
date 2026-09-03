//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_dto_source_timestamps.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataDtoSourceTimestamps {
  /// Returns a new [EventReviewDataDtoSourceTimestamps] instance.
  EventReviewDataDtoSourceTimestamps({
    required this.checkIns,

    required this.dailyRecords,

    required this.doseLogs,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: true)
  final String? checkIns;

  @JsonKey(name: r'dailyRecords', required: true, includeIfNull: true)
  final String? dailyRecords;

  @JsonKey(name: r'doseLogs', required: true, includeIfNull: true)
  final String? doseLogs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataDtoSourceTimestamps &&
          other.checkIns == checkIns &&
          other.dailyRecords == dailyRecords &&
          other.doseLogs == doseLogs;

  @override
  int get hashCode =>
      (checkIns == null ? 0 : checkIns.hashCode) +
      (dailyRecords == null ? 0 : dailyRecords.hashCode) +
      (doseLogs == null ? 0 : doseLogs.hashCode);

  factory EventReviewDataDtoSourceTimestamps.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewDataDtoSourceTimestampsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewDataDtoSourceTimestampsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
