//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'medicine_pagination_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicinePaginationDto {
  /// Returns a new [MedicinePaginationDto] instance.
  MedicinePaginationDto({
    required this.page,

    required this.pageSize,

    required this.total,

    required this.totalPages,
  });

  @JsonKey(name: r'page', required: true, includeIfNull: false)
  final num page;

  @JsonKey(name: r'pageSize', required: true, includeIfNull: false)
  final num pageSize;

  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @JsonKey(name: r'totalPages', required: true, includeIfNull: false)
  final num totalPages;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicinePaginationDto &&
          other.page == page &&
          other.pageSize == pageSize &&
          other.total == total &&
          other.totalPages == totalPages;

  @override
  int get hashCode =>
      page.hashCode + pageSize.hashCode + total.hashCode + totalPages.hashCode;

  factory MedicinePaginationDto.fromJson(Map<String, dynamic> json) =>
      _$MedicinePaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicinePaginationDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
