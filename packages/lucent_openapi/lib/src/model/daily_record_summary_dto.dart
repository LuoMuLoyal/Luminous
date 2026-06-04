//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_item_dto.dart';
import 'package:lucent_openapi/src/model/daily_record_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryDto {
  /// Returns a new [DailyRecordSummaryDto] instance.
  DailyRecordSummaryDto({required this.kind, required this.count, this.latest});

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DailyRecordKind.unknownDefaultOpenApi,
  )
  final DailyRecordKind kind;

  /// Count of records for this kind on the given date.
  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final num count;

  /// Most recent record of this kind.
  @JsonKey(name: r'latest', required: false, includeIfNull: false)
  final DailyRecordItemDto? latest;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryDto &&
          other.kind == kind &&
          other.count == count &&
          other.latest == latest;

  @override
  int get hashCode => kind.hashCode + count.hashCode + latest.hashCode;

  factory DailyRecordSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
