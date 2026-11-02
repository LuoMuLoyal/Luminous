//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_qa_chunk.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminQaChunk {
  /// Returns a new [AdminQaChunk] instance.
  AdminQaChunk({
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
    unknownEnumValue: AdminQaChunkSafetyLabelEnum.unknownDefaultOpenApi,
  )
  final AdminQaChunkSafetyLabelEnum safetyLabel;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminQaChunk &&
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

  factory AdminQaChunk.fromJson(Map<String, dynamic> json) =>
      _$AdminQaChunkFromJson(json);

  Map<String, dynamic> toJson() => _$AdminQaChunkToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum AdminQaChunkSafetyLabelEnum {
  @JsonValue(r'safe')
  safe(r'safe'),
  @JsonValue(r'caution')
  caution(r'caution'),
  @JsonValue(r'blocked')
  blocked(r'blocked'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AdminQaChunkSafetyLabelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
