// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_list_item_dto.dart';

part 'legal_document_list_data_dto.g.dart';

@JsonSerializable()
class LegalDocumentListDataDto {
  const LegalDocumentListDataDto({
    required this.items,
    required this.updatedAt,
  });

  factory LegalDocumentListDataDto.fromJson(Map<String, Object?> json) =>
      _$LegalDocumentListDataDtoFromJson(json);

  final List<LegalDocumentListItemDto> items;

  /// ISO-8601 timestamp of the most recent document update.
  final String updatedAt;

  Map<String, Object?> toJson() => _$LegalDocumentListDataDtoToJson(this);
}
