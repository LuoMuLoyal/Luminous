//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_search_item_dto.dart';
import 'package:lucent_api/src/model/medicine_pagination_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchDataDto {
  /// Returns a new [MedicineSearchDataDto] instance.
  MedicineSearchDataDto({required this.items, required this.pagination});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<MedicineSearchItemDto> items;

  @JsonKey(name: r'pagination', required: true, includeIfNull: false)
  final MedicinePaginationDto pagination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchDataDto &&
          other.items == items &&
          other.pagination == pagination;

  @override
  int get hashCode => items.hashCode + pagination.hashCode;

  factory MedicineSearchDataDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
