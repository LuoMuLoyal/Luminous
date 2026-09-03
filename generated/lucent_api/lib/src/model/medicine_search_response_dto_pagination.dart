//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_response_dto_pagination.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchResponseDtoPagination {
  /// Returns a new [MedicineSearchResponseDtoPagination] instance.
  MedicineSearchResponseDtoPagination({
    required this.page,

    required this.pageSize,

    required this.total,

    required this.totalPages,
  });

  /// Page number, 1-based.
  @JsonKey(name: r'page', required: true, includeIfNull: false)
  final num page;

  /// Page size.
  @JsonKey(name: r'pageSize', required: true, includeIfNull: false)
  final num pageSize;

  /// Total result count.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  /// Total page count.
  @JsonKey(name: r'totalPages', required: true, includeIfNull: false)
  final num totalPages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchResponseDtoPagination &&
          other.page == page &&
          other.pageSize == pageSize &&
          other.total == total &&
          other.totalPages == totalPages;

  @override
  int get hashCode =>
      page.hashCode + pageSize.hashCode + total.hashCode + totalPages.hashCode;

  factory MedicineSearchResponseDtoPagination.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineSearchResponseDtoPaginationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineSearchResponseDtoPaginationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
