// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_list_data_dto.dart';

part 'legal_document_list_response_dto.g.dart';

@JsonSerializable()
class LegalDocumentListResponseDto {
  const LegalDocumentListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory LegalDocumentListResponseDto.fromJson(Map<String, Object?> json) =>
      _$LegalDocumentListResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final LegalDocumentListDataDto data;

  Map<String, Object?> toJson() => _$LegalDocumentListResponseDtoToJson(this);
}
