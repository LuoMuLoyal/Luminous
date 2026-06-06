//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'create_daily_record_image_upload_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDailyRecordImageUploadDto {
  /// Returns a new [CreateDailyRecordImageUploadDto] instance.
  CreateDailyRecordImageUploadDto({
    required this.contentType,

    required this.sizeBytes,

    this.fileName,
  });

  /// Image MIME content type.
  @JsonKey(name: r'contentType', required: true, includeIfNull: false)
  final String contentType;

  /// File size in bytes.
  @JsonKey(name: r'sizeBytes', required: true, includeIfNull: false)
  final num sizeBytes;

  /// Original file name.
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDailyRecordImageUploadDto &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.fileName == fileName;

  @override
  int get hashCode =>
      contentType.hashCode + sizeBytes.hashCode + fileName.hashCode;

  factory CreateDailyRecordImageUploadDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDailyRecordImageUploadDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateDailyRecordImageUploadDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
