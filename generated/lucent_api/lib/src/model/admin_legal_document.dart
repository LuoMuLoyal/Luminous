//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_legal_document.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminLegalDocument {
  /// Returns a new [AdminLegalDocument] instance.
  AdminLegalDocument({
    required this.docType,

    required this.titleZh,

    required this.titleEn,

    required this.contentZh,

    required this.contentEn,

    required this.isActive,

    required this.updatedAt,
  });

  @JsonKey(name: r'docType', required: true, includeIfNull: false)
  final String docType;

  @JsonKey(name: r'titleZh', required: true, includeIfNull: false)
  final String titleZh;

  @JsonKey(name: r'titleEn', required: true, includeIfNull: false)
  final String titleEn;

  @JsonKey(name: r'contentZh', required: true, includeIfNull: false)
  final String contentZh;

  @JsonKey(name: r'contentEn', required: true, includeIfNull: false)
  final String contentEn;

  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminLegalDocument &&
          other.docType == docType &&
          other.titleZh == titleZh &&
          other.titleEn == titleEn &&
          other.contentZh == contentZh &&
          other.contentEn == contentEn &&
          other.isActive == isActive &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      docType.hashCode +
      titleZh.hashCode +
      titleEn.hashCode +
      contentZh.hashCode +
      contentEn.hashCode +
      isActive.hashCode +
      updatedAt.hashCode;

  factory AdminLegalDocument.fromJson(Map<String, dynamic> json) =>
      _$AdminLegalDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$AdminLegalDocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
