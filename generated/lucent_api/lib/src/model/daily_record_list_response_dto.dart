//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordListResponseDto {
  /// Returns a new [DailyRecordListResponseDto] instance.
  DailyRecordListResponseDto({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DailyRecordItemDto> items;

  /// Total records for the date (before pagination).
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordListResponseDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory DailyRecordListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
