//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'assistant_input_message_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantInputMessageDto {
  /// Returns a new [AssistantInputMessageDto] instance.
  AssistantInputMessageDto({required this.role, required this.content});

  /// Client-visible conversation role. system is not accepted.
  @JsonKey(
    name: r'role',
    required: true,
    includeIfNull: false,
    unknownEnumValue: AssistantInputMessageDtoRoleEnum.unknownDefaultOpenApi,
  )
  final AssistantInputMessageDtoRoleEnum role;

  /// Plain or Markdown-ready message content.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantInputMessageDto &&
          other.role == role &&
          other.content == content;

  @override
  int get hashCode => role.hashCode + content.hashCode;

  factory AssistantInputMessageDto.fromJson(Map<String, dynamic> json) =>
      _$AssistantInputMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantInputMessageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Client-visible conversation role. system is not accepted.
enum AssistantInputMessageDtoRoleEnum {
  /// Client-visible conversation role. system is not accepted.
  @JsonValue(r'user')
  user(r'user'),

  /// Client-visible conversation role. system is not accepted.
  @JsonValue(r'assistant')
  assistant(r'assistant'),

  /// Client-visible conversation role. system is not accepted.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AssistantInputMessageDtoRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
