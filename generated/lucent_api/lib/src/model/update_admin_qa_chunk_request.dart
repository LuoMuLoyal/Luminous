//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_admin_qa_chunk_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAdminQaChunkRequest {
  /// Returns a new [UpdateAdminQaChunkRequest] instance.
  UpdateAdminQaChunkRequest({this.question, this.answer, this.safetyLabel});

  @JsonKey(name: r'question', required: false, includeIfNull: false)
  final String? question;

  @JsonKey(name: r'answer', required: false, includeIfNull: false)
  final String? answer;

  @JsonKey(
    name: r'safetyLabel',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        UpdateAdminQaChunkRequestSafetyLabelEnum.unknownDefaultOpenApi,
  )
  final UpdateAdminQaChunkRequestSafetyLabelEnum? safetyLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAdminQaChunkRequest &&
          other.question == question &&
          other.answer == answer &&
          other.safetyLabel == safetyLabel;

  @override
  int get hashCode =>
      question.hashCode + answer.hashCode + safetyLabel.hashCode;

  factory UpdateAdminQaChunkRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAdminQaChunkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAdminQaChunkRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum UpdateAdminQaChunkRequestSafetyLabelEnum {
  @JsonValue(r'safe')
  safe(r'safe'),
  @JsonValue(r'caution')
  caution(r'caution'),
  @JsonValue(r'blocked')
  blocked(r'blocked'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UpdateAdminQaChunkRequestSafetyLabelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
