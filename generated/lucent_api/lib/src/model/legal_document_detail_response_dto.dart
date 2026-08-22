//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legal_document_detail_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LegalDocumentDetailResponseDto {
  /// Returns a new [LegalDocumentDetailResponseDto] instance.
  LegalDocumentDetailResponseDto({
    required this.docType,

    required this.title,

    required this.content,

    required this.updatedAt,
  });

  /// Document type identifier used in URL paths.
  @JsonKey(name: r'docType', required: true, includeIfNull: false)
  final String docType;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Markdown content of the document.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  /// ISO-8601 timestamp of last update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalDocumentDetailResponseDto &&
          other.docType == docType &&
          other.title == title &&
          other.content == content &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      docType.hashCode + title.hashCode + content.hashCode + updatedAt.hashCode;

  factory LegalDocumentDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocumentDetailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
