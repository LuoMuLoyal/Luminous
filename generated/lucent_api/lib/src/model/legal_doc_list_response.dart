//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/legal_doc_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legal_doc_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LegalDocListResponse {
  /// Returns a new [LegalDocListResponse] instance.
  LegalDocListResponse({required this.items, required this.updatedAt});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<LegalDocListResponseItems> items;

  /// ISO-8601 timestamp of the most recent document update.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalDocListResponse &&
          other.items == items &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => items.hashCode + updatedAt.hashCode;

  factory LegalDocListResponse.fromJson(Map<String, dynamic> json) =>
      _$LegalDocListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
