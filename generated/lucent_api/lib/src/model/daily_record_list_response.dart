//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordListResponse {
  /// Returns a new [DailyRecordListResponse] instance.
  DailyRecordListResponse({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DailyRecordListResponseItems> items;

  /// Total records for the date (before pagination).
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordListResponse &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory DailyRecordListResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
