//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legal_doc_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LegalDocListResponseItems {
  /// Returns a new [LegalDocListResponseItems] instance.
  LegalDocListResponseItems({
    required this.docType,

    required this.title,

    required this.updatedAt,
  });

  /// Document type identifier used in URL paths.
  @JsonKey(name: r'docType', required: true, includeIfNull: false)
  final String docType;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// ISO-8601 timestamp of last update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalDocListResponseItems &&
          other.docType == docType &&
          other.title == title &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => docType.hashCode + title.hashCode + updatedAt.hashCode;

  factory LegalDocListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$LegalDocListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
