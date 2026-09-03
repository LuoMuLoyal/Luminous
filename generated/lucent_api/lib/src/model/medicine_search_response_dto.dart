//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_search_response_dto_pagination.dart';
import 'package:lucent_api/src/model/medicine_search_response_dto_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchResponseDto {
  /// Returns a new [MedicineSearchResponseDto] instance.
  MedicineSearchResponseDto({required this.items, required this.pagination});

  /// Matched medicine items.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<MedicineSearchResponseDtoItemsInner> items;

  @JsonKey(name: r'pagination', required: true, includeIfNull: false)
  final MedicineSearchResponseDtoPagination pagination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchResponseDto &&
          other.items == items &&
          other.pagination == pagination;

  @override
  int get hashCode => items.hashCode + pagination.hashCode;

  factory MedicineSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
