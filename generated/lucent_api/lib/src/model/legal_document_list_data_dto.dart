//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/legal_document_list_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legal_document_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LegalDocumentListDataDto {
  /// Returns a new [LegalDocumentListDataDto] instance.
  LegalDocumentListDataDto({required this.items, required this.updatedAt});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<LegalDocumentListItemDto> items;

  /// ISO-8601 timestamp of the most recent document update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalDocumentListDataDto &&
          other.items == items &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => items.hashCode + updatedAt.hashCode;

  factory LegalDocumentListDataDto.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocumentListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
