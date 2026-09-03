//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'files_controller_create_upload_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FilesControllerCreateUploadV1Request {
  /// Returns a new [FilesControllerCreateUploadV1Request] instance.
  FilesControllerCreateUploadV1Request({
    required this.contentType,

    required this.sizeBytes,

    this.fileName,
  });

  /// MIME type
  @JsonKey(name: r'contentType', required: true, includeIfNull: false)
  final String contentType;

  /// File size in bytes
  // minimum: 0
  // maximum: 9007199254740991
  @JsonKey(name: r'sizeBytes', required: true, includeIfNull: false)
  final int sizeBytes;

  /// Original filename
  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilesControllerCreateUploadV1Request &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.fileName == fileName;

  @override
  int get hashCode =>
      contentType.hashCode + sizeBytes.hashCode + fileName.hashCode;

  factory FilesControllerCreateUploadV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$FilesControllerCreateUploadV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$FilesControllerCreateUploadV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
