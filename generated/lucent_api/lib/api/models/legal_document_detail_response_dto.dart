// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_detail_dto.dart';

part 'legal_document_detail_response_dto.g.dart';

@JsonSerializable()
class LegalDocumentDetailResponseDto {
  const LegalDocumentDetailResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory LegalDocumentDetailResponseDto.fromJson(Map<String, Object?> json) =>
      _$LegalDocumentDetailResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final LegalDocumentDetailDto data;

  Map<String, Object?> toJson() => _$LegalDocumentDetailResponseDtoToJson(this);
}
