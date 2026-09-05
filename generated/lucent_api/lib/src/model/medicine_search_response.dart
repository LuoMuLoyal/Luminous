//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_search_response_pagination.dart';
import 'package:lucent_api/src/model/medicine_search_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchResponse {
  /// Returns a new [MedicineSearchResponse] instance.
  MedicineSearchResponse({required this.items, required this.pagination});

  /// Matched medicine items.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<MedicineSearchResponseItems> items;

  @JsonKey(name: r'pagination', required: true, includeIfNull: false)
  final MedicineSearchResponsePagination pagination;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchResponse &&
          other.items == items &&
          other.pagination == pagination;

  @override
  int get hashCode => items.hashCode + pagination.hashCode;

  factory MedicineSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
