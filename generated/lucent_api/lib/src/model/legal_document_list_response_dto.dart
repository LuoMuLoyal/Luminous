//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/legal_document_list_response_dto_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legal_document_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LegalDocumentListResponseDto {
  /// Returns a new [LegalDocumentListResponseDto] instance.
  LegalDocumentListResponseDto({required this.items, required this.updatedAt});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<LegalDocumentListResponseDtoItemsInner> items;

  /// ISO-8601 timestamp of the most recent document update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalDocumentListResponseDto &&
          other.items == items &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => items.hashCode + updatedAt.hashCode;

  factory LegalDocumentListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocumentListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
