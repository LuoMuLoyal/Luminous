//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_qa_chunk_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminQaChunkListResponseItems {
  /// Returns a new [AdminQaChunkListResponseItems] instance.
  AdminQaChunkListResponseItems({
    required this.id,

    required this.qaId,

    required this.question,

    required this.answer,

    required this.safetyLabel,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'qaId', required: true, includeIfNull: false)
  final String qaId;

  @JsonKey(name: r'question', required: true, includeIfNull: false)
  final String question;

  @JsonKey(name: r'answer', required: true, includeIfNull: false)
  final String answer;

  @JsonKey(
    name: r'safetyLabel',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        AdminQaChunkListResponseItemsSafetyLabelEnum.unknownDefaultOpenApi,
  )
  final AdminQaChunkListResponseItemsSafetyLabelEnum safetyLabel;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminQaChunkListResponseItems &&
          other.id == id &&
          other.qaId == qaId &&
          other.question == question &&
          other.answer == answer &&
          other.safetyLabel == safetyLabel &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      qaId.hashCode +
      question.hashCode +
      answer.hashCode +
      safetyLabel.hashCode +
      updatedAt.hashCode;

  factory AdminQaChunkListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$AdminQaChunkListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$AdminQaChunkListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminQaChunkListResponseItemsSafetyLabelEnum {
  @JsonValue(r'safe')
  safe(r'safe'),
  @JsonValue(r'caution')
  caution(r'caution'),
  @JsonValue(r'blocked')
  blocked(r'blocked'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AdminQaChunkListResponseItemsSafetyLabelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
