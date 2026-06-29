//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'create_file_upload_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateFileUploadDto {
  /// Returns a new [CreateFileUploadDto] instance.
  CreateFileUploadDto({
    required this.contentType,

    required this.sizeBytes,

    this.fileName,
  });

  /// MIME type
  @JsonKey(name: r'contentType', required: true, includeIfNull: false)
  final String contentType;

  /// File size in bytes
  @JsonKey(name: r'sizeBytes', required: true, includeIfNull: false)
  final num sizeBytes;

  /// Original filename
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFileUploadDto &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.fileName == fileName;

  @override
  int get hashCode =>
      contentType.hashCode + sizeBytes.hashCode + fileName.hashCode;

  factory CreateFileUploadDto.fromJson(Map<String, dynamic> json) =>
      _$CreateFileUploadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateFileUploadDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
