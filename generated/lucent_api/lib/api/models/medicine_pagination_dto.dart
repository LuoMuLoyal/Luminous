// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'medicine_pagination_dto.g.dart';

@JsonSerializable()
class MedicinePaginationDto {
  const MedicinePaginationDto({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory MedicinePaginationDto.fromJson(Map<String, Object?> json) =>
      _$MedicinePaginationDtoFromJson(json);

  final num page;
  final num pageSize;
  final num total;
  final num totalPages;

  Map<String, Object?> toJson() => _$MedicinePaginationDtoToJson(this);
}
