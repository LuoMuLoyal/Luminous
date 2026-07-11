// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'legal_document_detail_dto.g.dart';

@JsonSerializable()
class LegalDocumentDetailDto {
  const LegalDocumentDetailDto({
    required this.docType,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory LegalDocumentDetailDto.fromJson(Map<String, Object?> json) =>
      _$LegalDocumentDetailDtoFromJson(json);

  /// Document type identifier used in URL paths.
  final String docType;
  final String title;

  /// Markdown content of the document.
  final String content;

  /// ISO-8601 timestamp of last update.
  final String updatedAt;

  Map<String, Object?> toJson() => _$LegalDocumentDetailDtoToJson(this);
}
