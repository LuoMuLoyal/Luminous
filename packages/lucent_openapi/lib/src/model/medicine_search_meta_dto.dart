//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_pagination_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_meta_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchMetaDto {
  /// Returns a new [MedicineSearchMetaDto] instance.
  MedicineSearchMetaDto({required this.pagination});

  @JsonKey(name: r'pagination', required: true, includeIfNull: false)
  final MedicinePaginationDto pagination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchMetaDto && other.pagination == pagination;

  @override
  int get hashCode => pagination.hashCode;

  factory MedicineSearchMetaDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchMetaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchMetaDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
