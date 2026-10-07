//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_admin_legal_document_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAdminLegalDocumentRequest {
  /// Returns a new [UpdateAdminLegalDocumentRequest] instance.
  UpdateAdminLegalDocumentRequest({
    this.titleZh,

    this.titleEn,

    this.contentZh,

    this.contentEn,

    this.isActive,
  });

  @JsonKey(name: r'titleZh', required: false, includeIfNull: false)
  final String? titleZh;

  @JsonKey(name: r'titleEn', required: false, includeIfNull: false)
  final String? titleEn;

  @JsonKey(name: r'contentZh', required: false, includeIfNull: false)
  final String? contentZh;

  @JsonKey(name: r'contentEn', required: false, includeIfNull: false)
  final String? contentEn;

  @JsonKey(name: r'isActive', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminLegalDocumentRequest &&
          other.titleZh == titleZh &&
          other.titleEn == titleEn &&
          other.contentZh == contentZh &&
          other.contentEn == contentEn &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      titleZh.hashCode +
      titleEn.hashCode +
      contentZh.hashCode +
      contentEn.hashCode +
      isActive.hashCode;

  factory UpdateAdminLegalDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAdminLegalDocumentRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateAdminLegalDocumentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
