//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/dose_log_list_response_dto_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoseLogListResponseDto {
  /// Returns a new [DoseLogListResponseDto] instance.
  DoseLogListResponseDto({required this.items, required this.total});

  /// Dose logs for the date.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<DoseLogListResponseDtoItemsInner> items;

  /// Total count of dose logs for the date.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseLogListResponseDto &&
          other.items == items &&
          other.total == total;

  @override
  int get hashCode => items.hashCode + total.hashCode;

  factory DoseLogListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DoseLogListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
