//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_records_controller_create_image_upload_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordsControllerCreateImageUploadV1Request {
  /// Returns a new [DailyRecordsControllerCreateImageUploadV1Request] instance.
  DailyRecordsControllerCreateImageUploadV1Request({
    required this.contentType,

    required this.sizeBytes,

    this.fileName,
  });

  /// Image MIME content type.
  @JsonKey(name: r'contentType', required: true, includeIfNull: false)
  final String contentType;

  /// File size in bytes.
  // minimum: 1
  // maximum: 50000000
  @JsonKey(name: r'sizeBytes', required: true, includeIfNull: false)
  final int sizeBytes;

  /// Original file name.
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordsControllerCreateImageUploadV1Request &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.fileName == fileName;

  @override
  int get hashCode =>
      contentType.hashCode + sizeBytes.hashCode + fileName.hashCode;

  factory DailyRecordsControllerCreateImageUploadV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordsControllerCreateImageUploadV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordsControllerCreateImageUploadV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
