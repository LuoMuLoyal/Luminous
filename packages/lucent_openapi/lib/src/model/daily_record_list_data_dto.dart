//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_list_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordListDataDto {
  /// Returns a new [DailyRecordListDataDto] instance.
  DailyRecordListDataDto({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DailyRecordItemDto> items;

  /// Total records for the date (before pagination).
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordListDataDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory DailyRecordListDataDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
