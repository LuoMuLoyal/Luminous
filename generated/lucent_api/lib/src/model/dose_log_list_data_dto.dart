//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/dose_log_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoseLogListDataDto {
  /// Returns a new [DoseLogListDataDto] instance.
  DoseLogListDataDto({required this.items, required this.total});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DoseLogItemDto> items;

  /// Total count of dose logs for the date.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogListDataDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory DoseLogListDataDto.fromJson(Map<String, dynamic> json) =>
      _$DoseLogListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
