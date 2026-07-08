// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_file_upload_dto.g.dart';

@JsonSerializable()
class CreateFileUploadDto {
  const CreateFileUploadDto({
    required this.contentType,
    required this.sizeBytes,
    this.fileName,
  });

  factory CreateFileUploadDto.fromJson(Map<String, Object?> json) =>
      _$CreateFileUploadDtoFromJson(json);

  /// MIME type
  final String contentType;

  /// File size in bytes
  final num sizeBytes;

  /// Original filename
  final String? fileName;

  Map<String, Object?> toJson() => _$CreateFileUploadDtoToJson(this);
}
