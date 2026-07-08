// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_data_export_request_dto_format_format.dart';
import 'create_data_export_request_dto_kind_kind.dart';
import 'create_data_export_request_dto_range_range.dart';

part 'create_data_export_request_dto.g.dart';

@JsonSerializable()
class CreateDataExportRequestDto {
  const CreateDataExportRequestDto({
    this.kind = CreateDataExportRequestDtoKindKind.hospital,
    this.format = CreateDataExportRequestDtoFormatFormat.pdf,
    this.range = CreateDataExportRequestDtoRangeRange.last7Days,
  });

  factory CreateDataExportRequestDto.fromJson(Map<String, Object?> json) =>
      _$CreateDataExportRequestDtoFromJson(json);

  /// Requested export kind.
  final CreateDataExportRequestDtoKindKind kind;

  /// Requested export format.
  final CreateDataExportRequestDtoFormatFormat format;

  /// Requested report range.
  final CreateDataExportRequestDtoRangeRange range;

  Map<String, Object?> toJson() => _$CreateDataExportRequestDtoToJson(this);
}
